package away3d.core.graphs
{
	import flash.utils.setTimeout;
	import flash.utils.getTimer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import away3d.arcane;
	import away3d.core.base.Vertex;
	import away3d.core.geom.NGon;
	import away3d.core.geom.Plane3D;
	import away3d.core.math.Number3D;
	
	use namespace arcane;
	
	// TO DO (important):
	// when partitioning, link to back portal
	// when sth not in vislist, other won't be in vislist of backportal
	internal final class BSPPortal extends EventDispatcher
	{
		public static const RECURSED_PORTAL_COMPLETE : String = "RecursedPortalComplete";
		public var index : int;
		public var nGon : NGon;
		//public var leaves : Vector.<BSPNode>;
		public var sourceNode : BSPNode;
		public var frontNode : BSPNode;
		public var backNode : BSPNode;
		public var listLen : int;
		public var frontList : Vector.<uint>;
		public var visList : Vector.<uint>;
		public var hasVisList : Boolean;
		public var frontOrder : int;
		public var maxTimeout : int = 0;
		
		public var antiPenumbrae : Array = [];
		
		public var mark : int;
		
		// containing all visible neighbours, through which we can see adjacent leaves
		public var neighbours : Vector.<BSPPortal>;
		
		// iteration for vis testing
		private static var TRAVERSE_PRE : int = 0;
		private static var TRAVERSE_IN : int = 1;
		private static var TRAVERSE_POST : int = 2;
		
		private var _iterationIndex : int;
		private var _state : int;
		private var _currentPortal : BSPPortal;
		private var _needCheck : Boolean;
		private var _numPortals : int;
		private var _backPortal : BSPPortal;		
		
		private static var _sizeLookUp : Vector.<int>;
		
		public var next : BSPPortal;
		
		arcane var _currentAntiPenumbra : Vector.<Plane3D>;
		arcane var _currentParent : BSPPortal;
		arcane var _currentFrontList : Vector.<uint>;
		
		private static var _planePool : Array = [];
		
		public function BSPPortal()
		{
			if (!_sizeLookUp) generateSizeLookUp();
			//leaves = new Vector.<BSPNode>();
			nGon = new NGon();
			// Math.round(Math.random()*0xffffff)
			//nGon.material = new WireColorMaterial(0xffffff, {alpha : .5});
			nGon.vertices = new Vector.<Vertex>();
		}
		
		// TO DO: change bits back to 32 for less mem usage and less iterations
		// checks how many bits are set in a byte
		// wait, I can actually combine this and 32 bit lists
		private function generateSizeLookUp() : void
		{
			var size : int = 255;
			var i : int = 1;
			var bit : int;
			var count : int;
			
			_sizeLookUp = new Vector.<int>(255);
			_sizeLookUp[0x00] = 0;
			
			do {
				count = 0;
				bit = 8;
				while (--bit >= 0)
					if (i & (1 << bit)) ++count;
					
				_sizeLookUp[i] = count;
			} while (++i < size);
			
			_sizeLookUp[0xff] = 8;
		}
		
		private function getPlaneFromPool() : Plane3D
		{
			return _planePool.length > 0? _planePool.pop() : new Plane3D();
		}
		
		private function addPlaneToPool(plane : Plane3D) : void
		{
			_planePool.push(plane);
		}
		
		public function fromNode(node : BSPNode, root : BSPNode) : Boolean
		{
			var bounds : Array = root._bounds;
			var plane : Plane3D = nGon.plane = node._partitionPlane;
			var dist : Number;
			var radius : Number;
			var direction1 : Number3D, direction2 : Number3D;
			var center : Number3D = new Number3D(	(root._minX+root._maxX)*.5,
													(root._minY+root._maxY)*.5,
													(root._minZ+root._maxZ)*.5 );
			var normal : Number3D = new Number3D(plane.a, plane.b, plane.c);
			var vertLen : int = 0;
			
			sourceNode = node;
			
			radius = center.distance(bounds[0]);
			radius = Math.sqrt(radius*radius + radius*radius);
			
			// calculate projection of aabb's center on plane
			dist = plane.distance(center);
			center.x -= dist*plane.a;
			center.y -= dist*plane.b; 
			center.z -= dist*plane.c;
			
			// perpendicular to plane normal & world axis, parallel to plane
			direction1 = getPerpendicular(normal);
			direction1.normalize();
			
			// perpendicular to plane normal & direction1, parallel to plane
			direction2 = new Number3D();
			direction2.cross(normal, direction1);
			direction2.normalize();
			
			// form very course bounds of bound projection on plane
			nGon.vertices[vertLen++] = new Vertex( 	center.x + direction1.x*radius,
													center.y + direction1.y*radius,
													center.z + direction1.z*radius);
			nGon.vertices[vertLen++] = new Vertex( 	center.x + direction2.x*radius,
													center.y + direction2.y*radius,
													center.z + direction2.z*radius);
			
			// invert direction
			direction1.normalize(-1);
			direction2.normalize(-1);
			
			nGon.vertices[vertLen++] = new Vertex( 	center.x + direction1.x*radius,
													center.y + direction1.y*radius,
													center.z + direction1.z*radius);
			nGon.vertices[vertLen++] = new Vertex( 	center.x + direction2.x*radius,
													center.y + direction2.y*radius,
													center.z + direction2.z*radius);
			
			// trim closely to world's bound planes
			trimToAABB(root);
			
			var prev : BSPNode = node; 
			while (node = node._parent) {
				// portal became too small
				if (!nGon || nGon.vertices.length < 3) return false;
				if (prev == node._positiveNode)
					nGon.trim(node._partitionPlane);
				else
					nGon.trimBack(node._partitionPlane);
				prev = node;
			}
			
			return true;
		}
		
		public function clone() : BSPPortal
		{
			var c : BSPPortal = new BSPPortal();
			c.nGon = nGon.clone();
			c.frontNode = frontNode;
			c.backNode = backNode;
			c.neighbours = neighbours;
			c._currentParent = _currentParent;
			c.frontList = frontList;
			c.visList = visList;
			c.index = index;
			return c;
		}
		
		private function trimToAABB(node : BSPNode) : void
		{
			var plane : Plane3D = new Plane3D(0, -1, 0, node._maxY);
			nGon.trim(plane);
			plane.b = 1; plane.d = -node._minY;
			nGon.trim(plane);
			plane.a = 1; plane.b = 0; plane.d = -node._minX;
			nGon.trim(plane);
			plane.a = -1; plane.d = node._maxX;
			nGon.trim(plane);
			plane.a = 0; plane.c = 1; plane.d = -node._minZ;
			nGon.trim(plane);
			plane.c = -1; plane.d = node._maxZ;
			nGon.trim(plane);
		}
		
		private function getPerpendicular(normal : Number3D) : Number3D
		{
			var p : Number3D = new Number3D();
			p.cross(new Number3D(1, 1, 0), normal);
			if (p.modulo < BSPTree.EPSILON) {
				p.cross(new Number3D(0, 1, 1), normal);
			}
			return p;
		}
		
		public function split(plane : Plane3D) : Vector.<BSPPortal>
		{
			var posPortal : BSPPortal;
			var negPortal : BSPPortal;
			var splits : Vector.<NGon> = nGon.split(plane);
			var ngon : NGon;
			var newPortals : Vector.<BSPPortal> = new Vector.<BSPPortal>(2);
			
			ngon = splits[0];
			if (ngon) {// && ngon.area > BSPTree.EPSILON) {
				posPortal = new BSPPortal();
				posPortal.nGon = ngon;
				//posPortal.nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
				posPortal.sourceNode = sourceNode;
				posPortal.frontNode = frontNode;
				posPortal.backNode = backNode;
				newPortals[0] = posPortal;
			}
			ngon = splits[1];
			if (ngon) {// && ngon.area > BSPTree.EPSILON) {
				negPortal = new BSPPortal();
				negPortal.nGon = ngon;
				negPortal.sourceNode = sourceNode;
				negPortal.frontNode = frontNode;
				negPortal.backNode = backNode;
				//negPortal.nGon.material = new WireColorMaterial(Math.round(Math.random()*0xffffff), {alpha : .5});
				newPortals[1] = negPortal;
			}
			
			return newPortals;
		}
		
		
		/**
		 * Returns a Vector containing the current portal as well as an inverted portal. The results will be treated as one-way portals.
		 */
		public function partition() : Vector.<BSPPortal>
		{
			var parts : Vector.<BSPPortal> = new Vector.<BSPPortal>(2);
			var inverted : BSPPortal = clone();

			inverted.frontNode = backNode;
			inverted.backNode = frontNode;
			inverted.nGon.invert();
			inverted._backPortal = this;
			_backPortal = inverted;
			
			parts[0] = this;
			parts[1] = inverted;
			return parts;
		}
		
		// this times out, or BSPTree:partitionPortals() ?
		public function createLists(numPortals : int) : void
		{
			_numPortals = numPortals;
			// only using 1 byte per item, as to keep the size look up table small
			listLen = (numPortals >> 5) + 1;
			frontList = new Vector.<uint>(listLen);
			visList = new Vector.<uint>(listLen);
			_currentFrontList = new Vector.<uint>(listLen);
		}

		public function addToList(list : Vector.<uint>, index : int) : void
		{
			list[index >> 5] |=  (1 << (index & 0x1f));
		}
		
		public function removeFromList(list : Vector.<uint>, index : int) : void
		{
			list[index >> 5] &= ~(1 << (index & 0x1f));
		}
		
		public function isInList(list : Vector.<uint>, index : int) : Boolean
		{
			if (!list) return false;
			return (list[index >> 5] & (1 << (index & 0x1f))) != 0;
		}
		
		public function findInitialFrontList(list : BSPPortal) : void
		{
			var srcPlane : Plane3D = nGon.plane;
			var i : int;
			var compNGon : NGon;
			var listIndex : int;
			var bitIndex : int;
			
			do {
				i = list.index;
				compNGon = list.nGon;
				// test if spanning or this portal is in front and other in back
				if (compNGon.classifyForPortalFront(srcPlane) && nGon.classifyForPortalBack(compNGon.plane)) {
					listIndex = index >> 5;
					bitIndex = index & 0x1f;
					// isInList(list.frontList, index)
					if ((list.frontList[listIndex] & (1 << bitIndex)) != 0) {
						// two portals can see eachother
						// removeFromList(list.frontList, index);
						list.frontList[listIndex] &= ~(1 << bitIndex);
						--list.frontOrder;
					}
					else {
						frontList[i >> 5] |=  (1 << (i & 0x1f));
						frontOrder++;
					}
				}
			} while (list = list.next);
		}
		
//		public function removeReciprocalVisibles(portals : Vector.<BSPPortal>) : void
//		{
//			var current : BSPPortal;
//			var len : int = portals.length;
//			var i : int = len;
//			
//			// no longer need this
//			backList = null;
//			
//			if (frontOrder <= 0) return;
//		
//			while (--i >= 0) {
//				current = portals[i];
//				if (isInList(frontList, i) && isInList(current.frontList, index)) {
//					removeFromList(frontList, i);
//					removeFromList(current.frontList, index);
//					frontOrder--;
//					current.frontOrder--;
//				}
//			}
//		}
		
		public function findNeighbours() : void
		{
			var backPortals : Vector.<BSPPortal> = frontNode._backPortals;
			var i : int = backPortals.length;
			
			var current : BSPPortal;
			var currIndex : int;
			var neighLen : int = 0;
			
			neighbours = new Vector.<BSPPortal>();
			
			while (--i >= 0) {
				current = backPortals[i];
				currIndex = current.index;
				
				//if (isInList(frontList, current.index)) {
				if (frontList[currIndex >> 5] & (1 << (currIndex & 0x1f))) {
					neighbours[neighLen++] = current;
					antiPenumbrae[currIndex] = generateAntiPenumbra(current.nGon);
				}
			}
			
			if (neighLen == 0) {
				i = listLen;
				while (--i >= 0)
					frontList[i] = 0;
				neighbours = null;
				frontOrder = 0;
			}
		}
		
		public function findVisiblePortals() : void
		{
			var i : int = listLen;
			_state = TRAVERSE_PRE;
			_currentPortal = this;
			_needCheck = false;
			_iterationIndex = 0;
			_currentParent = null;
			isInSequence = true;
			
			while (--i >= 0)
				_currentFrontList[i] = frontList[i];
				
			findVisiblePortalStep();
		}
		
		/*private function onRecursedComplete(event : Event) : void
		{
			setTimeout(dispatchEvent, 1, _recurseCompleteEvent);
		}*/
		
		public var isInSequence : Boolean;
		
		private function findVisiblePortalStep() : void
		{
			var next : BSPPortal;
			var startTime : int = getTimer();
			var currNeighbours : Vector.<BSPPortal>;
			var i : int;
			var parent : BSPPortal;
			var currFront : Vector.<uint>;
			
			do {
				if (_currentPortal.frontOrder <= 0)
					_state = TRAVERSE_POST;
				
				if (_needCheck) {
					// TO DO:
					// insert front list check here already to avoid method call
					//if (!isInList(currList, currentPortal.index))
					var currIndex : int = _currentPortal.index;
					parent = _currentPortal._currentParent;
					currFront = parent._currentFrontList;
					if (((currFront[currIndex >> 5] & (1 << (currIndex & 0x1f))) != 0) &&
							determineVisibility(_currentPortal)) {
						//addToList(visList, _currentPortal.index);
						visList[currIndex >> 5] |=  (1 << (currIndex & 0x1f));
						
						// we will be recursing down this one, so need an updated frontlist for this sequence
						i = listLen;
						while (--i >= 0)
							_currentPortal._currentFrontList[i] = currFront[i] & _currentPortal.frontList[i];
					}
					else
						_state = TRAVERSE_POST;
				}
				
				if (_state == TRAVERSE_PRE) {
					currNeighbours = _currentPortal.neighbours;
					if (currNeighbours) {
						next = currNeighbours[0];
						if (next.isInSequence)
							throw Error("Cycle!");
						next._iterationIndex = 0;
						next._currentParent = _currentPortal;
						_currentPortal = next;
						_currentPortal.isInSequence = true;
						_needCheck = true;
					}
					else {
						_state = TRAVERSE_POST;
//						_currentPortal._currentAntiPenumbra = null;
						_needCheck = false;
					}
				}
				else if (_state == TRAVERSE_IN) {
					currNeighbours = _currentPortal.neighbours;
					if (++_currentPortal._iterationIndex < currNeighbours.length) {
						next = currNeighbours[_currentPortal._iterationIndex];
						if (next.isInSequence)
							throw Error("Cycle!");
						next._iterationIndex = 0;
						next._currentParent = _currentPortal;
						_currentPortal = next;
						_currentPortal.isInSequence = true;
						_needCheck = true;
						_state = TRAVERSE_PRE;
					}
					else {
						_state = TRAVERSE_POST;
//						_currentPortal._currentAntiPenumbra = null;
						_needCheck = false;
					}
				}
				else if (_state == TRAVERSE_POST) {
					// clear memory
					var anti : Vector.<Plane3D> = _currentPortal._currentAntiPenumbra;
					// don't clean up neighbour penumbra, these are needed!
					// TO DO: are they actually still needed?
					if (anti && _currentPortal._currentParent != this) {
						i = anti.length;
				
						while (--i >= 0) {
							anti[i]._alignment = 0;
							_planePool.push(anti[i]);
						}
							
						_currentPortal._currentAntiPenumbra = null;
					}
						
					_currentPortal.isInSequence = false;
					_currentPortal = _currentPortal._currentParent;
					if (_currentPortal._iterationIndex < _currentPortal.neighbours.length-1)
						_state = TRAVERSE_IN;
						
					_needCheck = false;
				}
			} while(	(_currentPortal != this || _state != TRAVERSE_POST) &&
						getTimer() - startTime < maxTimeout);
			
			if (_currentPortal == this && _state == TRAVERSE_POST) {
				// update front list
				i = listLen;
				while (--i >= 0)
					frontList[i] = visList[i];
				
				isInSequence = false;
				hasVisList = true;
				setTimeout(notifyComplete, 1);
			}
			else {
				setTimeout(findVisiblePortalStep, 1);
			}
		}
		
		private function determineVisibility(currentPortal : BSPPortal) : Boolean
		{
			var currAntiPenumbra : Vector.<Plane3D>;
			var len : int;
			var i : int = listLen;
			var parent : BSPPortal = currentPortal._currentParent;
			var currentNGon : NGon;
			var clone : NGon;
			var currIndex : int = currentPortal.index;
			var vis : Vector.<uint>;
			var back : BSPPortal; 
			var thisBackIndex : int;
			
			if (parent == this) {
				// direct neighbour
				currentPortal._currentAntiPenumbra = antiPenumbrae[currIndex];
				return true;
			}
			
			// if not visible from other side 
			back = currentPortal._backPortal;
			if (back.hasVisList) {
				vis = back.visList;
				thisBackIndex = _backPortal.index;
				// not visible the other way around
				if ((vis[thisBackIndex >> 5] & (1 << (thisBackIndex & 0x1f))) == 0)
					return false;
			}
			
			currentNGon = currentPortal.nGon;
			currAntiPenumbra = parent._currentAntiPenumbra;
			len = currAntiPenumbra.length;
			
			i = len = currAntiPenumbra.length;
			
			while (--i >= 0) {
				//var classification : int = currentNGon.classifyToPlane(antiPenumbra[i]);
				// portal falls out of current antipenumbra	
				if (currentNGon.isOutAntiPenumbra(currAntiPenumbra[i]))
					return false;
			}
			
			// clone and trim current portal to visible antiPenumbra
			clone = currentNGon.clone();
			
			i = len;
			while (--i >= 0) {
				clone.trim(currAntiPenumbra[i]);
				if (clone.vertices.length < 3) return false;
			}
			
			if (clone.isNeglectable())
				return false;
			
			// create new antiPenumbra for the trimmed portal
			currentPortal._currentAntiPenumbra = generateAntiPenumbra(clone);
			
			return true;
		}
		
		private function notifyComplete() : void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function generateAntiPenumbra(targetNGon : NGon) : Vector.<Plane3D>
		{
			var anti : Vector.<Plane3D> = new Vector.<Plane3D>();
			var vertices1 : Vector.<Vertex> = nGon.vertices;
			var vertices2 : Vector.<Vertex> = targetNGon.vertices;
			var len1 : int = vertices1.length;
			var len2 : int = vertices2.length;
			var plane : Plane3D = _planePool.length > 0? _planePool.pop() : new Plane3D();
			var i : int;
			var j : int;
			var k : int;
			var p : int;
			var v1 : Vertex;
			var classification1 : int, classification2 : int;
			var antiLen : int = 0;
			var firstLen : int;
			var d1x : Number, d1y : Number, d1z : Number,
				d2x : Number, d2y : Number, d2z : Number;
			var v2 : Vertex, v3 : Vertex;
			var nx : Number, ny : Number, nz : Number, l : Number, d : Number;
			var compPlane : Plane3D;
			var check : Boolean;
			var da : Number, db : Number, dc : Number, dd : Number;
			
			i = len1;
			while (--i >= 0) {
				v1 = vertices1[i];
				j = len2;
				k = len2-2;
				while (--j >= 0) {
					v2 = vertices2[j];
					v3 = vertices2[k];
					//plane.from3vertices(v1, v2, v3);
					//plane.normalize();
					d1x = v2.x-v1.x;
					d1y = v2.y-v1.y;
					d1z = v2.z-v1.z;
					d2x = v3.x-v1.x;
					d2y = v3.y-v1.y;
					d2z = v3.z-v1.z;
					nx = d1y*d2z - d1z*d2y;
            		ny = d1z*d2x - d1x*d2z;
            		nz = d1x*d2y - d1y*d2x;
            		l = 1/Math.sqrt(nx*nx+ny*ny+nz*nz);
            		nx *= l; ny *= l; nz *= l;
					plane.a = nx;
            		plane.b = ny;
            		plane.c = nz;
					plane.d = d = -(nx*v1.x + ny*v1.y + nz*v1.z);
					
					classification1 = nGon.classifyToPlane(plane);
					classification2 = targetNGon.classifyToPlane(plane);
					
					if (	(classification1 == Plane3D.FRONT && classification2 == Plane3D.BACK) ||
							(classification1 == Plane3D.BACK && classification2 == Plane3D.FRONT)) {
/*					if (	(classification1 != Plane3D.INTERSECT && classification2 != Plane3D.INTERSECT) &&
							(classification1 != classification2)) {*/
						// planes coming out of the target portal should face inward
						if (classification2 == Plane3D.BACK) {
							plane.a = -nx;
							plane.b = -ny;
							plane.c = -nz;
							plane.d = -d;
						} 
						
						p = antiLen;
	            		check = true;
	            		while (--p >= 0) {
	            			compPlane = anti[p];
	            			da = compPlane.a - nx;
	            			db = compPlane.b - ny;
	            			dc = compPlane.c - nz;
	            			dd = compPlane.d - d;
	            			if (	da < BSPTree.EPSILON && da > -BSPTree.EPSILON &&
	            					db < BSPTree.EPSILON && db > -BSPTree.EPSILON &&
	            					dc < BSPTree.EPSILON && dc > -BSPTree.EPSILON &&
	            					dd < BSPTree.EPSILON && dd > -BSPTree.EPSILON) {
	            				p = 0;
	            				check = false;
	            			}
	            		}
	            		
	            		if (check) {
							anti[antiLen++] = plane;
							plane = _planePool.length > 0? _planePool.pop() : new Plane3D();
	            		}
					}
					
					if (--k < 0) k = len2-1;
				}
			}
			
			firstLen = antiLen;
			
			i = len2;
			while (--i >= 0) {
				v1 = vertices2[i];
				j = len1;
				k = len1-2;
				while (--j >= 0) {
					v2 = vertices1[j];
					v3 = vertices1[k];
//					plane.from3vertices(v1, vertices1[j], vertices1[k]);
//					plane.normalize();
					d1x = v2.x-v1.x;
					d1y = v2.y-v1.y;
					d1z = v2.z-v1.z;
					d2x = v3.x-v1.x;
					d2y = v3.y-v1.y;
					d2z = v3.z-v1.z;
					nx = d1y*d2z - d1z*d2y;
            		ny = d1z*d2x - d1x*d2z;
            		nz = d1x*d2y - d1y*d2x;
            		l = 1/Math.sqrt(nx*nx+ny*ny+nz*nz);
            		nx *= l; ny *= l; nz *= l;
            		d = -(nx*v1.x + ny*v1.y + nz*v1.z);
            		
            		plane.a = nx;
	            	plane.b = ny;
	            	plane.c = nz;
	            	plane.d = d;
	            		
					classification1 = nGon.classifyToPlane(plane);
					classification2 = targetNGon.classifyToPlane(plane);
						
					if (	(classification1 == Plane3D.FRONT && classification2 == Plane3D.BACK) ||
							(classification1 == Plane3D.BACK && classification2 == Plane3D.FRONT)) {
						if (classification2 == Plane3D.BACK) {
							plane.a = -nx;
							plane.b = -ny;
							plane.c = -nz;
							plane.d = -d;
						} 
						
						p = antiLen;
	            		check = true;
	            		while (--p >= 0) {
	            			compPlane = anti[p];
	            			da = compPlane.a - nx;
	            			db = compPlane.b - ny;
	            			dc = compPlane.c - nz;
	            			dd = compPlane.d - d;
	            			if (	da < BSPTree.EPSILON && da > -BSPTree.EPSILON &&
	            					db < BSPTree.EPSILON && db > -BSPTree.EPSILON &&
	            					dc < BSPTree.EPSILON && dc > -BSPTree.EPSILON &&
	            					dd < BSPTree.EPSILON && dd > -BSPTree.EPSILON) {
	            				p = 0;
	            				check = false;
	            			}
	            		}
	            		
	            		if (check) {
							anti[antiLen++] = plane;
							plane = _planePool.length > 0? _planePool.pop() : new Plane3D();
	            		}
					}
            	}
				if (--k < 0) k = len1-1;
			}
			
			return anti;
		}
		
		
		
		public function removePortalsFromNeighbours(portals : Vector.<BSPPortal>) : void
		{
			if (frontOrder <= 0) return;
			
			var current : BSPPortal;
			var i : int = portals.length;
			var len : int = neighbours.length;
			var count : int;
			var j : int;
			var neigh : BSPPortal;
			
			while (--i >= 0) {
				current = portals[i];
				
				// only check if not neighbour and already in front list
				if (isInList(frontList, i) && neighbours.indexOf(current) == -1) {
					count = 0;
					
					j = len;
					while (--j >= 0) {
						neigh = neighbours[j];
						
						// is in front and in anti-pen, escape loop
						if (isInList(neigh.frontList, i) && current.checkAgainstAntiPenumbra(antiPenumbrae[neigh.index]))
							j = 0;
						else
							++count;
					}
					
					// not visible from portal through any neighbour
					if (count == len) {
						removeFromList(frontList, i);
						frontOrder--;
					}
				}
			}
		}
		
		public function propagateVisibility() : void
		{
			var j : int;
			var k : int;
			var list : Vector.<uint> = new Vector.<uint>(listLen);
			var neighbour : BSPPortal;
			var neighList : Vector.<uint>;
			var neighIndex : int;
			
			if (frontOrder <= 0) return;
			
			j = neighbours.length-1;
			
			// find all portals visible from any neighbour
			// first in list, copy front list
			neighbour = neighbours[j];
			neighList = neighbour.frontList;
			k = listLen;
			while (--k >= 0)
				list[k] = neighList[k];

			neighIndex = neighbour.index;
			list[neighIndex >> 5] |=  (1 << (neighIndex & 0x1f));
			
			// add other neighbours' visible lists into the mix
			while (--j >= 0) {
				neighbour = neighbours[j];
				neighList = neighbour.frontList;
				k = listLen;
				while (--k >= 0)
					list[k] |= neighList[k];

				neighIndex = neighbour.index;
				list[neighIndex >> 5] |=  (1 << (neighIndex & 0x1f));
			}
			
			k = listLen;
			// only visible if visible from neighbours and visible from current
			while (--k >= 0)
				frontList[k] &= list[k];
			
			frontOrder = 0;
			k = listLen;
			var val : uint;
			while (--k >= 0) {
				val = frontList[k];
				frontOrder += _sizeLookUp[val & 0xff];
				frontOrder += _sizeLookUp[(val >> 8) & 0xff];
				frontOrder += _sizeLookUp[(val >> 16) & 0xff];
				frontOrder += _sizeLookUp[(val >> 24) & 0xff];
			}
		}

		private function checkAgainstAntiPenumbra(antiPenumbra : Vector.<Plane3D>) : Boolean
		{
			var i : int = antiPenumbra.length;
			
			while (--i >= 0)
				if (nGon.isOutAntiPenumbra(antiPenumbra[i])) return false;
				/*if (nGon.classifyToPlane(antiPenumbra[i]) == Plane3D.BACK ||
					nGon.classifyToPlane(antiPenumbra[i]) == -2)
					return false;*/
			return true;
			
		}
	}
}