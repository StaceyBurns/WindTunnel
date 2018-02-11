package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.DisplayObject;
	import nape.space.Space;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	import nape.util.Debug;
	import nape.util.ShapeDebug;
	import nape.callbacks.*;
	import XMLData.XmlData;





	public class Nape extends Sprite {
		var xmlData: XmlData = new XmlData(); //instiate xml
		public var wind;
		public var gravX;
		public var city;
		public var gravY = -1000; //manually set y speed
		public var space: Space = new Space(new Vec2(500, gravY)); //hard code default x gravity in case of errors
		private var hitInteractionListener: InteractionListener; // listen for events on borders
		private var winInteractionListener: InteractionListener; //listen for events on finish line
		private var wallCollisionType: CbType = new CbType(); //callbacks for collision detection
		private var blockCollisionType: CbType = new CbType();
		private var winCollisionType: CbType = new CbType();
		public var windSpeed;
		public var windDir = "-";
		public function Nape(): void {}
		public var block: Polygon;
		public var blockBody: Body;
		public var spawnCount = 0;

		public function init() {
			trace("gravX = "+gravX);
			hitInteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, wallCollisionType, blockCollisionType, hitBorder); //activate listeners on borders and finish line
			winInteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, winCollisionType, blockCollisionType, hitWin); // and set callback for them on collision
			space.listeners.add(hitInteractionListener); // add these listeners to the space
			space.listeners.add(winInteractionListener);

			var debug: ShapeDebug = new ShapeDebug(1024, 768, 0x131313);
			//addChild(debug.display);

			var border: Body = new Body(BodyType.STATIC); //borders for collision detection
			border.shapes.add(new Polygon(Polygon.rect(400, 668, 224, 100))); //bottom
			border.shapes.add(new Polygon(Polygon.rect(0, 0, 400, 768))); //left
			border.shapes.add(new Polygon(Polygon.rect(624, 0, 400, 768))); //right
			border.cbTypes.add(wallCollisionType) //add callback type to borders
			border.space = space; //add borders to the nape space

			var finishLine: Body = new Body(BodyType.STATIC); //finish line to hit, off screen at top
			finishLine.shapes.add(new Polygon(Polygon.rect(0, -100, 1024, 50))); //top
			finishLine.cbTypes.add(winCollisionType)
			finishLine.space = space;

			addEventListener(Event.ENTER_FRAME, function (e: Event): void {
				debug.clear();
				space.step(1 / stage.frameRate, 10, 10);
				//debug.draw(space);
				debug.flush();

				var bodyList = space.bodies;
				for (var i: int = 0; i < bodyList.length; i++) {
					var body: Body = bodyList.at(i);
					if (body.userData.sprite != null) {
						body.userData.sprite.x = body.position.x
						body.userData.sprite.y = body.position.y
						body.userData.sprite.rotation = (body.rotation * 180 / Math.PI) % 360;
					}
				}﻿
			});
		}
		public function hitWin(collision: InteractionCallback): void { //when player reached the finish/win line
			trace("WIN!!!!!!!");
			blockBody.space = null; // set block to null in space to remove
			block = null; //set block to null so that only 1 block at a time can be addded
			removeChild(blockBody.userData.sprite); //remove the reference
			space.bodies.remove(blockBody); //remove the block from space
			graphics.clear();
			graphics.beginFill(Math.random() * 0xFFFFFF, 0.5); //change background colour
			graphics.drawRect(0, 0, 400, 768);
			graphics.drawRect(400, 668, 224, 100);
			graphics.drawRect(624, 0, 400, 768);
			graphics.endFill();
			spawnBox();
		}
		public function hitBorder(collision: InteractionCallback): void { // when player hits border/loses
			blockBody.space = null; // set block to null in space to remove
			block = null; //set block to null so that only 1 block at a time can be addded
			removeChild(blockBody.userData.sprite);
			space.bodies.remove(blockBody);
			graphics.clear();
			graphics.beginFill(0x000000,0.5);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
			spawnCount = 0;
		}
		
		public function getWind():void { //get wind data from xml class - loosely following observer design pattern
			if(xmlData.windSpeed <= 30){ // if the speed is less than 30 set windSpeed to the windspeed of the current loaded city
		windSpeed= xmlData.windSpeed;
		} else { // or else set it to 30
			windSpeed = 30;
		}
		if(xmlData.currentWindDir.indexOf("E") >= 0){ //if wind is reading east set the wind direction to +
		windDir ="+";
		}else if(xmlData.currentWindDir.indexOf("W") >= 0){ //if wind is reading west set wind direction to -
		windDir ="-";
		}else if(xmlData.currentWindDir.indexOf("W") == 0 || xmlData.currentWindDir.indexOf("E") == 0){ //if wind is neither east/west in XML, default to -
		windDir="-";
		}
		}
		
				function negateWind():void{ //make gravX (on screen wind) negative/reverse direction if wind direction is -
			if(windDir == "-") {
				var reverseWind;
				reverseWind = Math.abs(gravX)*2; //return value of gravX and double it
				gravX = gravX - reverseWind; //take this away from gravX to make number negative
			}
		}
		

		public function spawnBox(): void { //handles spawning of new box and resetting of world variables for new box
			block = new Polygon(Polygon.box(50, 50)); //make new nape body and fill it with graphics, give it set position on stage
			blockBody = new Body();
			var sprite: Sprite = new Sprite();
			sprite.graphics.beginFill(0xffffff, 1);
			sprite.graphics.drawRect(-25, -25, 50, 50);
			sprite.graphics.endFill();
			addChild(sprite);
			blockBody.cbTypes.add(blockCollisionType) // add the callback type for collision
			blockBody.shapes.add(block);
			blockBody.position.setxy(500, 600);
			blockBody.space = space;
			blockBody.userData.sprite = sprite;
			addChild(blockBody.userData.sprite);
			xmlData.loadCity(); //loadCity from xml to refresh xml data
			city = xmlData.city;
			getWind(); //get wind details from refreshed data
			wind =  windSpeed * 50; //set wind speed
			gravX = wind; //reset gravity var
			negateWind(); //make wind negative if necessary
			space.gravity = (new Vec2(gravX, gravY)); //set gravity in the space to new values
			spawnCount ++;
		}
	}

}