package away3d.loaders.utils;

import away3d.core.utils.Debug;
import away3d.loaders.data.ChannelData;


/**
 * Store for all animation channels associated with an externally loaded file.
 */
class ChannelLibrary extends Hash<ChannelData>  {
	
	private var _channel:ChannelData;
	private var _channelArray:Array<ChannelData>;
	private var _channelArrayDirty:Bool;
	

	private function updateChannelArray():Void {
		
		_channelArray = [];
		for (_channel in this.iterator()) {
			if (_channel != null) {
				_channelArray.push(_channel);
			}
		}

	}

	/**
	 * Adds an animation channel name reference to the library.
	 */
	public function addChannel(name:String, xml:Xml):ChannelData {
		//return if animation already exists
		
		if ((this.get(name) != null)) {
			return this.get(name);
		}
		_channelArrayDirty = true;
		var channelData:ChannelData = new ChannelData();
		channelData.xml = xml;
		channelData.name = name;
		this.set(name, channelData);
		return channelData;
	}

	/**
	 * Returns an animation channel data object for the given name reference in the library.
	 */
	public function getChannel(name:String):ChannelData {
		//return if animation exists
		
		if ((this.get(name) != null)) {
			return this.get(name);
		}
		Debug.warning("Channel '" + name + "' does not exist");
		return null;
	}

	/**
	 * Returns an array of all animation channels.
	 */
	public function getChannelArray():Array<ChannelData> {
		
		if (_channelArrayDirty) {
			updateChannelArray();
		}
		return _channelArray;
	}

	// autogenerated
	public function new () {
		super();
		
	}

	

}
