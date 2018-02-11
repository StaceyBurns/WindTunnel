package XMLData {
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class XmlData {
		public var myXML:XML;
		public var myLoader:URLLoader = new URLLoader();
		public var city = "";
		public var windSpeed = 10;
		public var currentWindDir ="";
		var cities:Array = new Array("Paris", "Berlin", "Cork", "Dubai", "Chicago", "Beijing", "Tokyo", "Lisbon", "Mumbai", "Mexico", "Sydney", "Texas", "Hawaii", "Moscow");


		public function XmlData() {
			// constructor code

		}
		public function loadCity():void{
			city = cities[Math.floor(Math.random()*14)];
			trace(city);
			myLoader.load(new URLRequest("http://api.apixu.com/v1/current.xml?key=ec8f429a01374587bf5151332173011&q="+ city));
			myLoader.addEventListener(Event.COMPLETE, processXML);
		}
		function processXML(e:Event):void {
		myXML = new XML(e.target.data);
		currentWindDir = myXML.current.wind_dir;
		windSpeed = myXML.current.wind_kph;
		}

	}
	
}
