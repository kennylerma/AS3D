package flare.loaders 
{

    import flare.basic.*;
    import flare.core.*;
    import flare.flsl.*;
    import flare.materials.*;
    import flare.materials.filters.*;
    import flare.modifiers.*;
    import flare.system.*;
    import flare.utils.*;
    import flash.display3D.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.utils.*;
    
    public class ColladaLoader2 extends Pivot3D implements ILibraryExternalItem
    {
        private var _daeImages:Dictionary;
        private var _daeFilters:Dictionary;
        private var _flipNormals:Boolean;
        private var _daeSurfaces:Dictionary;
        private var _daeSkinRoots:Dictionary;
        private var _daeUpdateControllers:Array;
        private var _daeUpdateSkeletons:Array;
        private var _daeCameras:Dictionary;
        private var _daeLights:Dictionary;
        private var _daeMaterials:Dictionary;
        private var _loader:flash.net.URLLoader;
        private var _parsed:Boolean;
        private var _axis:int=0;
        private var _file:String;
        private var _library:Library3D;
        private var _loaded:Boolean;
        private var _cullFace:String;
        private var _nullMaterials:Dictionary;
        private var _folder:String="";
        private var _texturesFolder:String;
        private var _loadCount:int;
        private var _request:*;
        private var _skinRoot:Pivot3D;
        private var _sceneContext:Scene3D;
        private var _parent:Pivot3D;
        private var _dae:XML;
        private var _daeNodes:Dictionary;
        private var _daeSid:Array;
        private var _daeGeometry:Dictionary;
        private var _daeAnimation:Dictionary;
        private var _daeIndices:Dictionary;
        private var _daeControllers:Dictionary;
        public static var requestTexture:Function;
        private var _fuckingInstanceNodes:Array;
		
		public function ColladaLoader2(arg1:*, arg2:Pivot3D=null, arg3:Scene3D=null, arg4:String=null, arg5:Boolean=false, arg6:String="back")
        {
            var loc1:*=0;
            _nullMaterials = new Dictionary(true);
            _daeSid = [];
            _daeNodes = new Dictionary(true);
            _daeGeometry = new Dictionary(true);
            _daeAnimation = new Dictionary(true);
            _daeIndices = new Dictionary(true);
            _daeControllers = new Dictionary(true);
            _daeImages = new Dictionary(true);
            _daeFilters = new Dictionary(true);
            _daeMaterials = new Dictionary(true);
            _daeSurfaces = new Dictionary(true);
            _daeSkinRoots = new Dictionary(true);
            _daeUpdateControllers = [];
            _daeUpdateSkeletons = [];
            _daeCameras = new Dictionary(true);
            _daeLights = new Dictionary(true);
            _fuckingInstanceNodes = [];
            _skinRoot = new Pivot3D("Skin Root");
			
            _parent = arg2 || this;
            _texturesFolder = arg4;
            _flipNormals = arg5;
            _cullFace = arg6;
            _request = arg1;
            _sceneContext = arg3;
            if (_request is XML) 
            {
                _dae = _request;
                if (arg4) 
                {
                    _folder = _texturesFolder;
                }
                else 
                {
                    _folder = "";
                }
            }
            else if (_request is String) 
            {
                arg1 = arg1.replace(new RegExp("\\\\", "g"), "/");
                loc1 = arg1.lastIndexOf("/");
                if (arg4) 
                {
                    _folder = _texturesFolder;
                }
                else if (loc1 != -1) 
                {
                    _folder = arg1.substr(0, loc1 + 1);
                }
                _file = arg1;
                name = arg1.substr(arg1.lastIndexOf("/") + 1);
            }
            return;
        }

        public function get bytesTotal():uint
        {
            return (_loader ? _loader.bytesTotal : 0) + (_library ? _library.bytesTotal : 0);
        }

        public function get bytesLoaded():uint
        {
            return (_loader ? _loader.bytesLoaded : 0) + (_library ? _library.bytesLoaded : 0);
        }

        public function load():void
        {
            if (_dae) 
            {
                start();
                return;
            }
            if (_loader) 
            {
                return;
            }
            _loader = new URLLoader();
            _loader.dataFormat = URLLoaderDataFormat.TEXT;
            _loader.addEventListener("progress", dispatchEvent, false, 0, true);
            _loader.addEventListener("complete", completeEvent, false, 0, true);
            _loader.load(new URLRequest(_file));
            return;
        }

        public function close():void
        {
            if (_loader) 
            {
                _loader.close();
            }
            return;
        }

        public function get loaded():Boolean
        {
            return _loaded;
        }

        private function completeEvent(arg1:Event):void
        {
            var e:Event;
            var str:String;
            var l:int;

            var loc1:*;
            str = null;
            l = 0;
            e = arg1;
            e.stopImmediatePropagation();
			str = String(_loader.data).replace(' xmlns="http://www.collada.org/2005/11/COLLADASchema" version="1.4.1"', "");
			
			//trace("ColladaLoader2.completeEvent() data: " + str);
			
            try 
            {
                _dae = new XML(str);
            }
            catch (e:*)
            {
                do 
                {
                    l = str.length;
                    str = str.replace("\"<", "\"");
                }
                while (l != str.length);
                do 
                {
                    l = str.length;
                    str = str.replace(">\"", "\"");
                }
                while (l != str.length);
                _dae = new XML(str);
            }
            start();
        }

        public static function extract(weightTable:Vector.<Array>, surface:Surface3D, indices:Vector.<uint>):void
        {
            var loc7:*=0;
            var loc8:*=NaN;
            var loc1:Vector.<Number> = new Vector.<Number>();
            var loc2:Vector.<Number> = new Vector.<Number>();
            var loc3:*= 0;
			
            while (loc3 < indices.length) 
            {
                var index:int = indices[loc3];
                var weightArr:Array = (index < weightTable.length) ? weightTable[index] : null;
                if (weightArr == null || weightArr.length == 0) 
                {
                    var loc9:int = Device3D.maxBonesPerVertex;
                }
                else 
                {
                    var weight:Number = 0;
                    loc7 = 0;
                    while (loc7 < Device3D.maxBonesPerVertex) 
                    {
                        weight = weight + weightArr[loc7].weight;
                        loc7++;
                    }
					
                    if (weight < 0.99 || weight > 1.01) 
                    {
                        loc8 = 1 - weight;
                        loc7 = 0;
                        while (loc7 < Device3D.maxBonesPerVertex) 
                        {
                            weightArr[loc7].weight = weightArr[loc7].weight + weightArr[loc7].weight / weight * loc8;
                            loc7++;
                        }
                    }
					
                    loc9 = Device3D.maxBonesPerVertex;
                }
				
                loc3++;
            }
			
            surface.addVertexData(Surface3D.SKIN_WEIGHTS, Device3D.maxBonesPerVertex, loc1);
            surface.addVertexData(Surface3D.SKIN_INDICES, Device3D.maxBonesPerVertex, loc2);
        }

        private function start():void
        {
            //trace("ColladaLoader2.start()");
			var node:XML;
            var visualSceneNodes:XMLList;
            var iNode:Object;
            
			if (_parsed) return;
            _parsed = true;
			
            if (_dae.asset.up_axis.text() == "Y_UP") _axis = 1;
			//trace("Axis: " + _dae.asset.up_axis.text());
			
            var instanceVisualSceneUrl:String = String(_dae.scene.instance_visual_scene.@url).substr(1);
            var sceneIndex:int = 0;
            var visualScenes:XMLList = _dae.library_visual_scenes.visual_scene;
            var sceneNodes:XMLList = new XMLList("");
            for each (var visualScene:XML in visualScenes) 
            {
				if (visualScene.@id == instanceVisualSceneUrl) 
				{
					//trace("Found Visual Scene: " + instanceVisualSceneUrl);
					sceneNodes[sceneIndex] = visualScene;
					sceneIndex++;
				}
            }
            visualSceneNodes = sceneNodes.node;
            
            var cameras:XMLList = _dae.library_cameras.camera;
            for each (node in cameras) 
            {
                getCamera(node);
            }
            
            var lights:XMLList = _dae.library_lights.light;
            for each (node in lights) 
            {
                getLight(node);
            }
            
            var images:XMLList = _dae.library_images.image;
            for each (node in images) 
            {
                getImage(node);
            }
            
            var materials:XMLList = _dae.library_materials.material;
            for each (node in materials) 
            {
                getEffect(node);
            }
            
            var geometries:XMLList = _dae.library_geometries.geometry;
            for each (node in geometries) 
            {
				//trace("Get Geometry");
				var geomSurfaces:Vector.<Surface3D> = getGeometry(node);
				//trace("getGeometry() Surfaces: " + geomSurfaces[0].vertexVector);
            }
            
            var controllers:XMLList = _dae.library_controllers.controller;
            for each (node in controllers) 
            {
                getController(node);
            }
			
            var z:int = _dae.library_nodes.node.length() - 1;
            while (z >= 0) 
            {
                getNode(_dae.library_nodes.node[z]);
                z--;
            }
            
            for each (node in visualSceneNodes) 
            {
                //trace("addChild: " + getNode(node).getSurfaces()[0].vertexVector);
				_parent.addChild(getNode(node));
            }
            for each (iNode in _fuckingInstanceNodes) 
            {
                iNode.pivot.addChild(_daeNodes[iNode.id].clone());
            }
            
            var animations:XMLList = _dae.library_animations.animation;
            for each (node in animations) 
            {
                getAnimation(node);
            }
            
            for each (node in _daeUpdateControllers) 
            {
                updateController(node);
            }
			
            frameSpeed = frameSpeed;
			
            if (_axis == 1) 
            {
                rotateX(-90, false, Vector3DUtils.ZERO);
            }
			
            play();
			
            if (!_library || _loadCount == 0) 
            {
                _loaded = true;
                dispatchEvent(new Event("complete"));
            }
			
            _daeNodes = null;
            _daeGeometry = null;
            _daeAnimation = null;
            _daeIndices = null;
            _daeControllers = null;
            _daeImages = null;
            _daeFilters = null;
            _daeSurfaces = null;
            _daeUpdateControllers = null;
            _daeUpdateSkeletons = null;
            _daeSkinRoots = null;
            _daeSid = null;
            _dae = null;
            _nullMaterials = null;
        }

        private function optimizeSurfaces(arg1:Mesh3D):void
        {
            var loc1:*=null;
            var loc2:*=0;
            var loc3:*=arg1.surfaces;
            for each (loc1 in loc3) 
            {
                Surface3DUtils.compress(loc1);
            }
            return;
        }

        private function getEffect(arg1:XML):void
        {
            var node:XML;
            var sourceEffect:String;
            var effect:XMLList;
            var technique:XMLList;
            var material:XML;
            var filters:Array;
            var channel:String;
            var colorComponents:Array;
            var color:int;
            var texture:Texture3D;
            var sampler:XMLList;
            var surface:XMLList;
            var init_from:String;
            var specularTexture:Texture3D;
            var sampler2:XMLList;
            var surface2:XMLList;
            var init_from2:String;

            var loc1:*;
            sourceEffect = null;
            effect = null;
            technique = null;
            material = null;
            filters = null;
            channel = null;
            colorComponents = null;
            color = 0;
            texture = null;
            sampler = null;
            surface = null;
            init_from = null;
            specularTexture = null;
            sampler2 = null;
            surface2 = null;
            init_from2 = null;
            node = arg1;
            sourceEffect = node.instance_effect.@url.substr(1);
            var loc3:*=0;
            var loc4:*=_dae.library_effects.effect;
            var loc2:*=new XMLList("");
            for each (var loc5:* in loc4) 
            {
                var loc6:*;
                with (loc6 = loc5) 
                {
                    if (@id == sourceEffect) 
                    {
                        loc2[loc3] = loc5;
                    }
                }
            }
            effect = loc2;
            technique = effect.profile_COMMON.technique;
            if (technique.children().length() > 0) 
            {
                material = technique.children()[0];
                filters = [];
                if (material.diffuse != undefined) 
                {
                    channel = material.diffuse.texture.@texcoord;
                    if (material.diffuse.color != undefined) 
                    {
                        colorComponents = material.diffuse.color.split(new RegExp("\\s+"));
                        color = combineRGB(colorComponents[0] * 255, colorComponents[1] * 255, colorComponents[2] * 255);
                        filters.push(new ColorFilter(color, Number(colorComponents[3])));
                    }
                    if (material.diffuse.texture != undefined) 
                    {
                        texture = _daeImages[material.diffuse.texture[0].@texture.toString()];
                    }
                    if (!texture) 
                    {
                        loc3 = 0;
                        loc4 = effect.profile_COMMON.newparam;
                        loc2 = new XMLList("");
                        for each (loc5 in loc4) 
                        {
                            with (loc6 = loc5) 
                            {
                                if (@sid == material.diffuse.texture.@texture) 
                                {
                                    loc2[loc3] = loc5;
                                }
                            }
                        }
                        sampler = loc2;
                        loc3 = 0;
                        loc4 = effect.profile_COMMON.newparam;
                        loc2 = new XMLList("");
                        for each (loc5 in loc4) 
                        {
                            with (loc6 = loc5) 
                            {
                                if (@sid == sampler.sampler2D.source.text()) 
                                {
                                    loc2[loc3] = loc5;
                                }
                            }
                        }
                        surface = loc2;
                        init_from = surface.surface.init_from.text();
                        texture = _daeImages[init_from];
                    }
                    if (texture) 
                    {
                        filters.push(new TextureMapFilter(texture, channel != "CHANNEL1" ? 0 : 1));
                    }
                }
                if (material.specular != undefined) 
                {
                    if (material.specular.texture == undefined) 
                    {
                        if (!(Number(material.shininess.float) > 0)) 
                        {
                        };
                    }
                    else 
                    {
                        specularTexture = _daeImages[material.specular.texture[0].@texture.toString()];
                        if (!specularTexture) 
                        {
                            loc3 = 0;
                            loc4 = effect.profile_COMMON.newparam;
                            loc2 = new XMLList("");
                            for each (loc5 in loc4) 
                            {
                                with (loc6 = loc5) 
                                {
                                    if (@sid == material.specular.texture.@texture) 
                                    {
                                        loc2[loc3] = loc5;
                                    }
                                }
                            }
                            sampler2 = loc2;
                            loc3 = 0;
                            loc4 = effect.profile_COMMON.newparam;
                            loc2 = new XMLList("");
                            for each (loc5 in loc4) 
                            {
                                with (loc6 = loc5) 
                                {
                                    if (@sid == sampler2.sampler2D.source.text()) 
                                    {
                                        loc2[loc3] = loc5;
                                    }
                                }
                            }
                            surface2 = loc2;
                            init_from2 = surface2.surface.init_from.text();
                            specularTexture = _daeImages[init_from2];
                        }
                        if (specularTexture) 
                        {
                            filters.push(new SpecularMapFilter(specularTexture, Number(material.shininess.float)));
                        }
                    }
                }
                if (material.bump != undefined) 
                {
                    trace("Bump map!");
                }
                _daeFilters[node.@id.toString()] = filters;
            }
            return;
        }

        private function combineRGB(arg1:int, arg2:int, arg3:int):int
        {
            return arg1 << 16 | arg2 << 8 | arg3;
        }

        private function getImage(arg1:XML):void
        {
            if (!_library) 
            {
                _library = new Library3D(1);
                _library.addEventListener("progress", resourceProgressEvent, false, 0, true);
                _library.addEventListener("complete", resourceCompleteEvent, false, 0, true);
            }
            var loc1:*=arg1.init_from.text();
            loc1 = loc1.replace(new RegExp("\\\\", "g"), "/");
            while (loc1.charAt(0) == "/") 
            {
                loc1 = loc1.substr(1);
            }
            var loc2:*=_folder;
            while (loc1.indexOf("../") == 0) 
            {
                loc2 = loc2.substr(0, loc2.lastIndexOf("/", loc2.length - 2)) + "/";
                loc1 = loc1.substr(3);
            }
            if (loc1.indexOf("file://") != -1) 
            {
                loc1 = loc2 + loc1.substr(loc1.lastIndexOf("/") + 1);
            }
            else 
            {
                loc1 = loc2 + loc1;
            }
            if (ColladaLoader2.requestTexture != null) 
            {
                _daeImages[arg1.@id.toString()] = ColladaLoader2.requestTexture(loc1);
                return;
            }
            var loc3:*=libraryContext.getItem(loc1) as Texture3D;
            var loc4:*=loc1.substr(-3).toLowerCase();
            if (!(loc4 == "jpg") && !(loc4 == "png")) 
            {
                trace("Error: Invalid texture format", loc4, "in file", loc1);
                loc3 = new Texture3D(Device3D.nullBitmapData);
            }
            if (!loc3) 
            {
                loc3 = new Texture3D(loc1, false);
                if (scene) 
                {
                    loc3.scene = scene;
                }
                libraryContext.addItem(loc1, loc3);
                _library.push(loc3);
                var loc5:*;
                var loc6:*=((loc5 = this)._loadCount + 1);
                loc5._loadCount = loc6;
            }
            _daeImages[arg1.@id.toString()] = loc3;
            return;
        }

        private function resourceProgressEvent(e:Event):void
        {
            dispatchEvent(e);
            return;
        }

        private function resourceCompleteEvent(e:Event):void
        {
            _loaded = true;
            if (scene) 
            {
                upload(scene);
            }
            dispatchEvent(new Event("complete"));
            return;
        }

        private function getAnimation(arg1:XML):void
        {
            var node:XML = arg1;
            var anim:XML;
            var channel:XML;
            var channelSource:String;
            var sampler:XMLList;
            var sourceInput:String;
            var sourceOutput:String;
            var input:XMLList;
            var output:XMLList;
            var values:Array;
            var frames:Vector.<Frame3D>;
            var target:String;
            
            for each (anim in node.animation) 
            {
                getAnimation(anim);
            }
            
            for each (channel in node.channel) 
            {
                channelSource = channel.@source.substr(1);
                var loc5:*=0;
                var loc4:*=new XMLList("");
                for each (var loc7:* in node.sampler) 
                {
					if (loc7.@id == channelSource) 
					{
						loc4[loc5] = loc7;
					}
                }
                sampler = loc4;
				
                loc5 = 0;
                loc4 = new XMLList("");
                for each (loc7 in sampler.input) 
                {
					if (loc7.@semantic == "INPUT") 
					{
						loc4[loc5] = loc7;
					}
                }
                sourceInput = loc4.@source.substr(1);
				
                loc5 = 0;
                loc4 = new XMLList("");
                for each (loc7 in sampler.input) 
                {
					if (loc7.@semantic == "OUTPUT") 
					{
						loc4[loc5] = loc7;
					}
                }
                sourceOutput = loc4.@source.substr(1);
				
                loc5 = 0;
                loc4 = new XMLList("");
                for each (loc7 in node.source) 
                {
					if (loc7.@id == sourceInput) 
					{
						loc4[loc5] = loc7;
					}
                }
                input = loc4;
				
                loc5 = 0;
                loc4 = new XMLList("");
                for each (loc7 in node.source) 
                {
					if (loc7.@id == sourceOutput) 
					{
						loc4[loc5] = loc7;
					}
                }
                output = loc4;
				
                if (output.technique_common.accessor.param.@type.toString() != "float4x4") continue;
                if (int(output.float_array.@count) == 0)  continue;
				
                values = output.float_array.text().split(new RegExp("\\s+"));
                frames = new Vector.<Frame3D>();
                while (values.length) 
                {
                    frames.push(getMatrix(values.splice(0, 16)));
                }
                _daeAnimation[node.@id.toString()] = frames;
                target = String(channel.@target).split("/")[0];
                if (_daeSid[target] != undefined) 
                {
                    _daeSid[target].frames = frames;
                    continue;
                }
                if (_daeNodes[target] == undefined) 
                {
                    continue;
                }
                _daeNodes[target].frames = frames;
            }
        }

        private function bindMaterial(arg1:XMLList, arg2:Mesh3D, arg3:FLSLFilter):void
        {
            var loc2:*=null;
            var loc3:*=null;
            var loc4:*=null;
            var loc5:*=null;
            var loc6:*=null;
            var loc1:*=0;
            while (loc1 < arg1.technique_common.instance_material.length()) 
            {
                loc2 = arg1.technique_common.instance_material[loc1];
                loc3 = loc2.@symbol;
                loc4 = loc2.@target;
                loc4 = loc4.substr(1);
                loc5 = _daeMaterials[loc4];
                if (!_daeMaterials[loc4]) 
                {
                    loc5 = new Shader3D(loc4, _daeFilters[loc4], true, arg3);
                    _daeMaterials[loc4] = loc5;
                }
                var loc7:*=0;
                var loc8:*=arg2.surfaces;
                for each (loc6 in loc8) 
                {
                    if (loc6.offset[Surface3D.NORMAL] == -1) 
                    {
                        trace("Warning: Missing NORMAL buffer, creating dummy one.");
                        loc6.addVertexData(Surface3D.NORMAL, 3, new Vector.<Number>(loc6.vertexVector.length / loc6.sizePerVertex * 3));
                    }
                    if (loc6.offset[Surface3D.UV0] == -1) 
                    {
                        trace("Warning: Missing UV0 buffer, creating dummy one.");
                        loc6.addVertexData(Surface3D.UV0, 2, new Vector.<Number>(loc6.vertexVector.length / loc6.sizePerVertex * 2));
                    }
                    if (_daeSurfaces[loc6] != loc3) 
                    {
                        continue;
                    }
                    loc6.material = loc5;
                }
                ++loc1;
            }
            loc7 = 0;
            loc8 = arg2.surfaces;
            for each (loc6 in loc8) 
            {
                if (loc6.material != null) 
                {
                    continue;
                }
                if (!_nullMaterials[arg3]) 
                {
                    _nullMaterials[arg3] = new Shader3D("", [new ColorFilter()], true, arg3);
                }
                loc6.material = _nullMaterials[arg3];
            }
            return;
        }

        private function bindMaterial3(arg1:XMLList, arg2:Mesh3D, arg3:FLSLFilter):void
        {
            var loc2:*=null;
            var loc3:*=0;
            var loc4:*=null;
            var loc5:*=null;
            var loc6:*=null;
            var loc7:*=null;
            var loc8:*=null;
            var loc9:*=0;
            var loc1:*=0;
            while (loc1 < arg1.length()) 
            {
                loc2 = arg1[loc1];
                loc3 = 0;
                while (loc3 < loc2.bind_material.technique_common.instance_material.length()) 
                {
                    loc4 = loc2.bind_material.technique_common.instance_material[loc3];
                    loc5 = loc4.@symbol;
                    loc6 = loc4.@target;
                    loc6 = loc6.substr(1);
                    loc7 = _daeMaterials[loc6];
                    if (!_daeMaterials[loc6]) 
                    {
                        loc7 = new Shader3D(loc6, _daeFilters[loc6], true, arg3);
                        _daeMaterials[loc6] = loc7;
                    }
                    loc9 = 0;
                    while (loc9 < _daeGeometry[loc2.@url.substr(1)].length) 
                    {
                        loc8 = _daeGeometry[loc2.@url.substr(1)][loc9];
                        if (loc8.offset[Surface3D.NORMAL] == -1) 
                        {
                            trace("Warning: Missing NORMAL buffer, creating dummy one.");
                            loc8.addVertexData(Surface3D.NORMAL, 3, new Vector.<Number>(loc8.vertexVector.length / loc8.sizePerVertex * 3));
                        }
                        if (loc8.offset[Surface3D.UV0] == -1) 
                        {
                            trace("Warning: Missing UV0 buffer, creating dummy one.");
                            loc8.addVertexData(Surface3D.UV0, 2, new Vector.<Number>(loc8.vertexVector.length / loc8.sizePerVertex * 2));
                        }
                        if (_daeSurfaces[loc8] == loc5) 
                        {
                            loc8.material = loc7;
                        }
                        ++loc9;
                    }
                    ++loc3;
                }
                ++loc1;
            }
            var loc10:*=0;
            var loc11:*=arg2.surfaces;
            for each (loc8 in loc11) 
            {
                if (loc8.material != null) 
                {
                    continue;
                }
                if (!_nullMaterials[arg3]) 
                {
                    _nullMaterials[arg3] = new Shader3D("", [new ColorFilter()], true, arg3);
                }
                loc8.material = _nullMaterials[arg3];
            }
            return;
        }

        private function uintSplit(arg1:String, arg2:Vector.<uint>=null):Vector.<uint>
        {
            var loc2:*=0;
            var loc3:*=0;
            var loc4:*=0;
            var loc6:*=null;
            if (!arg2) 
            {
                arg2 = new Vector.<uint>();
            }
            var loc1:*=" ";
            var loc5:*=arg1.length;
            while (loc2 < loc5) 
            {
                loc6 = arg1.charAt(loc2);
                if (loc6 == loc1) 
                {
                    ++loc2;
                    var loc7:*=loc4++;
                    arg2[loc7] = uint(arg1.substring(loc3, loc2));
                    ++loc3;
                }
                ++loc2;
            }
            loc7 = loc4++;
            arg2[loc7] = uint(arg1.substring(loc3, loc2));
            return arg2;
        }
		
        private function getNode(node:XML):Pivot3D
        {
            var pivot:Pivot3D;
            var mesh:Mesh3D;
			
            if (node.@id.toString() != "" && _daeNodes[node.@id.toString()]) 
            {
                return _daeNodes[node.@id.toString()];
            }
			
            if (node.instance_geometry == undefined) 
            {
                if (node.instance_controller == undefined) 
                {
                    if (node.instance_camera == undefined) 
                    {
                        if (node.instance_light == undefined) 
                        {
                            pivot = new Pivot3D(node.@name || node.@id);
                        }
                        else 
                        {
                            pivot = getLight(node);
                        }
                    }
                    else 
                    {
                        pivot = getCamera(node);
                    }
                }
                else 
                {
                    mesh = _daeControllers[node.instance_controller.@url.substr(1)].mesh;
                    mesh.name = node.@name;
                    if (mesh.modifier is SkinModifier) 
                    {
                        _daeUpdateSkeletons.push(node.instance_controller.skeleton.text());
                    }
                    bindMaterial(node.instance_controller.bind_material, mesh, Shader3D.VERTEX_SKIN);
                    pivot = mesh;
                }
            }
            else 
            {
                mesh = new Mesh3D(node.@name || node.@id);
                var geoms:XMLList = node.instance_geometry;
                for each (var geom:XML in geoms) 
                {
					var surfaceID:String = geom.@url.substr(1);
					var daeSurfaces:Vector.<Surface3D> = _daeGeometry[surfaceID];
					mesh.surfaces = mesh.surfaces.concat(daeSurfaces);
                }
				
                if (mesh.surfaces.length) 
                {
                    //bindMaterial3(node.instance_geometry, mesh, Shader3D.VERTEX_NORMAL);
                    Mesh3DUtils.split(mesh);
                }
                pivot = mesh;
				
				trace("Mesh Surface: " + mesh.getSurfaces()[0].vertexVector);
            }
			
            _daeNodes[node.@id.toString()] = pivot;
			
            if (node.instance_node != undefined) 
            {
                var instanceURL:String = node.instance_node.@url.substr(1);
                _fuckingInstanceNodes.push({"pivot":pivot, "id":instanceURL});
            }
			
            var childNodes:XMLList = node.children();
			var i:int = 0;
            while (i < childNodes.length()) 
            {
                var child:XML = childNodes[i];
                var childName:String = child.localName();
				//trace("ColladaLoader.getNode() childName: " + childName);
				i++;
            }
			
            if (node.@sid != undefined) 
            {
                _daeSid[node.@sid] = pivot;
            }
			
            pivot.updateTransforms();
            return pivot;
        }

        private function getController(arg1:XML):Modifier
        {
            var node:XML = arg1;
            var controller:XMLList;
            var mesh:Mesh3D;
            var skin:SkinModifier;
            var source:String;
            var daeWeights:XMLList;
            var vWeights:Array;
            var vCount:Array;
            var v:Array;
            var t:int;
            var weightTable:Vector.<Array>;
            var i:int;
            var s:Surface3D;
            var weightVertexArray:Array;
            var e:int = 0;
            var joint:int;
            var weight:int;
            var value:Number;
            
            if (node.morph != undefined) 
            {
                trace("Morph Controllers are not supported");
                return null;
            }
			
            if (_daeControllers[node.@id]) 
            {
                return _daeControllers[node.@id];
            }
			
            if (node.skin) 
            {
                controller = node.skin;
                mesh = new Mesh3D(controller.@source);
                mesh.surfaces = _daeGeometry[controller.@source.substr(1)];
                skin = new SkinModifier();
                skin.mesh = mesh;
                skin.bindTransform.copyFrom(mesh.world);
                _daeSkinRoots[skin.root] = 1;
				
                var loc3:*=0;
                var loc2:*=new XMLList("");
                for each (var loc5:* in controller.vertex_weights.input) 
                {
					if (loc5.@semantic == "WEIGHT") 
					{
						loc2[loc3] = loc5;
					}
                }
                source = loc2.@source.substr(1);
				
                loc3 = 0;
                loc2 = new XMLList("");
                for each (loc5 in controller.source) 
                {
					if (loc5.@id == source) 
					{
						loc2[loc3] = loc5;
					}
                }
                daeWeights = loc2;
                vWeights = daeWeights.float_array.text().split(new RegExp("\\s+"));
                vCount = controller.vertex_weights.vcount.text().split(new RegExp("\\s+"));
                v = controller.vertex_weights.v.text().split(new RegExp("\\s+"));
                t = 0;
                weightTable = new Vector.<Array>();
                i = 0;
                while (i < vCount.length) 
                {
                    weightVertexArray = [];
                    e = 0;
                    while (e < vCount[i]) 
                    {
                        t = (t + 1);
                        joint = v[t];
                        t = (t + 1);
                        weight = v[t];
                        value = vWeights[weight];
                        if (value > 0) 
                        {
                            weightVertexArray.push({"joint":joint, "weight":value});
                        }
                        e++;
                    }
                    if (weightVertexArray.length > Device3D.maxBonesPerVertex) 
                    {
                        weightVertexArray.sortOn("weight", Array.DESCENDING);
                        weightVertexArray.splice(Device3D.maxBonesPerVertex);
                    }
                    else if (weightVertexArray.length > 0) 
                    {
                        while (weightVertexArray.length < Device3D.maxBonesPerVertex) 
                        {
                            weightVertexArray.push({"joint":0, "weight":0});
                        }
                    }
                    weightTable[i] = weightVertexArray;
                    i++;
                }
                mesh.modifier = skin;
             
                for each (s in mesh.surfaces) 
                {
                    extract(weightTable, s, _daeIndices[s]);
                }
                _daeControllers[node.@id.toString()] = skin;
                _daeUpdateControllers.push(node);
                return skin;
            }
            return null;
        }

        private function updateController(arg1:XML):void
        {
            var node:XML;
            var skin:flare.modifiers.SkinModifier;
            var controller:XMLList;
            var bindMatrix:Frame3D;
            var sourceJoints:String;
            var sourceMatrix:String;
            var daeJoints:XMLList;
            var daeInvBindMatrix:XMLList;
            var joints:Array;
            var invMatrix:Array;
            var sid:String;
            var bone:Pivot3D;
            var root:Pivot3D;
            var f:Frame3D;
            var i:int;

            var loc1:*;
            controller = null;
            bindMatrix = null;
            sourceJoints = null;
            sourceMatrix = null;
            daeJoints = null;
            daeInvBindMatrix = null;
            joints = null;
            invMatrix = null;
            sid = null;
            bone = null;
            root = null;
            f = null;
            i = 0;
            node = arg1;
            skin = _daeControllers[node.@id.toString()];
            if (skin) 
            {
                controller = node.skin;
                bindMatrix = controller.bind_shape_matrix != undefined ? getMatrix(controller.bind_shape_matrix.text().split(new RegExp("\\s+"))) : new Frame3D();
                var loc3:*=0;
                var loc4:*=controller.joints.input;
                var loc2:*=new XMLList("");
                for each (var loc5:* in loc4) 
                {
                    var loc6:*;
                    with (loc6 = loc5) 
                    {
                        if (@semantic == "JOINT") 
                        {
                            loc2[loc3] = loc5;
                        }
                    }
                }
                sourceJoints = loc2.@source.substr(1);
                loc3 = 0;
                loc4 = controller.joints.input;
                loc2 = new XMLList("");
                for each (loc5 in loc4) 
                {
                    with (loc6 = loc5) 
                    {
                        if (@semantic == "INV_BIND_MATRIX") 
                        {
                            loc2[loc3] = loc5;
                        }
                    }
                }
                sourceMatrix = loc2.@source.substr(1);
                loc3 = 0;
                loc4 = controller.source;
                loc2 = new XMLList("");
                for each (loc5 in loc4) 
                {
                    with (loc6 = loc5) 
                    {
                        if (@id == sourceJoints) 
                        {
                            loc2[loc3] = loc5;
                        }
                    }
                }
                daeJoints = loc2;
                loc3 = 0;
                loc4 = controller.source;
                loc2 = new XMLList("");
                for each (loc5 in loc4) 
                {
                    with (loc6 = loc5) 
                    {
                        if (@id == sourceMatrix) 
                        {
                            loc2[loc3] = loc5;
                        }
                    }
                }
                daeInvBindMatrix = loc2;
                if (daeJoints.Name_array == undefined) 
                {
                    if (daeJoints.IDREF_array != undefined) 
                    {
                        joints = daeJoints.IDREF_array.text().split(new RegExp("\\s+"));
                    }
                }
                else 
                {
                    joints = daeJoints.Name_array.text().split(new RegExp("\\s+"));
                }
                invMatrix = daeInvBindMatrix.float_array.text().split(new RegExp("\\s+"));
                skin.invBoneMatrix = new Vector.<Matrix3D>();
                loc2 = 0;
                loc3 = joints;
                for each (sid in loc3) 
                {
                    bone = _daeSid[sid];
                    if (_daeSid[sid] == undefined) 
                    {
                        if (_daeNodes[sid] == undefined) 
                        {
                            bone = getChildByName(sid);
                        }
                        else 
                        {
                            bone = _daeNodes[sid];
                        }
                    }
                    else 
                    {
                        bone = _daeSid[sid];
                    }
                    skin.addBone(bone);
                    skin.invBoneMatrix.push(getMatrix(invMatrix.splice(0, 16)));
                    skin.invBoneMatrix[skin.invBoneMatrix.length - 1].prepend(bindMatrix);
                    root = bone;
                    while (!(root.parent == null) && !(root.parent == this) && _daeSkinRoots[root.parent] == null && !(root.parent == _skinRoot) && !(root.parent == _parent)) 
                    {
                        root = root.parent;
                    }
                    root.parent = _skinRoot;
                }
                skin.root.parent = null;
                skin.root.lock = true;
                skin.root.visible = false;
                skin.root = _skinRoot;
                skin.update();
                flare.modifiers.SkinModifier.split(skin, skin.mesh.surfaces);
                if (skin.mesh.frames == null) 
                {
                    f = new Frame3D(skin.mesh.transform.rawData);
                    skin.mesh.transform = f;
                    skin.mesh.frames = new Vector.<Frame3D>();
                    i = 0;
                    while (i < skin.totalFrames) 
                    {
                        skin.mesh.frames.push(f);
                        ++i;
                    }
                }
            }
            return;
        }

        private function getCamera(arg1:XML):Camera3D
        {
            var loc2:*=null;
            var loc3:*=null;
            var loc1:*=arg1.instance_camera.@url.toString();
            loc1 = loc1.slice(1, loc1.length);
            if (_daeCameras[loc1]) 
            {
                return _daeCameras[loc1];
            }
            if (arg1.optics.technique_common.perspective != undefined) 
            {
                loc2 = new Camera3D(arg1.@name || arg1.@id);
                loc3 = arg1.optics.technique_common.perspective;
                loc2.fieldOfView = loc3.yfov;
                loc2.aspectRatio = loc3.aspect_ratio;
                loc2.near = loc3.znear;
                loc2.far = loc3.zfar;
                _daeCameras[arg1.@id.toString()] = loc2;
            }
            return loc2;
        }

        private function getLight(arg1:XML):Light3D
        {
            var loc2:*=null;
            var loc3:*=null;
            var loc4:*=null;
            var loc1:*=arg1.instance_light.@url.toString();
            loc1 = loc1.slice(1, loc1.length);
            if (_daeLights[loc1]) 
            {
                return _daeLights[loc1];
            }
            if (arg1.technique_common.point == undefined) 
            {
                if (arg1.technique_common.ambient == undefined) 
                {
                    loc2 = new Light3D(arg1.@name || arg1.@id);
                    _daeLights[arg1.@id.toString()] = loc2;
                }
                else 
                {
                    loc2 = new Light3D(arg1.@name || arg1.@id);
                    _daeLights[arg1.@id.toString()] = loc2;
                }
            }
            else 
            {
                loc3 = arg1.technique_common.point;
                loc4 = loc3.color.toString().split(" ");
                loc2 = new Light3D(arg1.@name || arg1.@id);
                loc2.color.x = loc4[0];
                loc2.color.y = loc4[1];
                loc2.color.z = loc4[2];
                loc2.attenuation = Number(loc3.constant_attenuation);
                _daeLights[arg1.@id.toString()] = loc2;
            }
            return loc2;
        }

        private function numberSplit(arg1:String, arg2:Vector.<Number>=null):Vector.<Number>
        {
            var loc1:*=0;
            var loc2:*=0;
            var loc3:*=0;
            if (!arg2) 
            {
                arg2 = new Vector.<Number>();
            }
            while (true) 
            {
                loc2 = loc1;
                loc1 = arg1.indexOf(" ", loc1);
                if (loc1 != -1) 
                {
                    var loc4:*=loc3++;
                    arg2[loc4] = Number(arg1.substring(loc2, loc1++));
                    continue;
                }
                break;
            }
            loc4 = loc3++;
            arg2[loc4] = Number(arg1.substring(loc2));
            return arg2;
        }

        private function getGeometry(geomXML:XML):Vector.<Surface3D>
        {
            var node:XML = geomXML;
            var surfaces:Vector.<Surface3D> = new Vector.<Surface3D>();
            var lastLength:uint = 0;
            var primitive:XMLList;
            var readInputs:Function;
            var pushVertex:Function;
            var length:int = 0;
            var inputType:int = 0;
            var inputSize:int = 0;
			
            if (_daeGeometry[node.@id]) 
            {
                trace("Geometry ID: " + _daeGeometry[node.@id]);
				return _daeGeometry[node.@id];
            }
			
            _daeGeometry[node.@id.toString()] = surfaces;
			
			// Parse Mesh geometry
            if (node.mesh != undefined) 
            {
                //trace("Found Mesh!");
				var sources:Array = [];
               
                for each (var src:XML in node.mesh.source) 
                {
                    sources[src.@id.toString()] = { "values":numberSplit(src.float_array), "stride":src.technique_common.accessor.@stride };
					//trace("Source: " + src.@id.toString() + ", values: " + numberSplit(src.float_array) + ", stride: " + src.technique_common.accessor.@stride);
                }
                if (node.mesh.triangles != undefined) primitive = node.mesh.triangles;
                if (node.mesh.polygons != undefined) primitive = node.mesh.polygons;
                if (node.mesh.polylist != undefined) primitive = node.mesh.polylist;
				
                if (primitive) 
                {
                    for each (var tri:XML in primitive) 
                    {
						readInputs = function (inputList:XMLList):void
                        {
                            //trace("inputList: " + inputList);
							for each (var input:XML in inputList) 
                            {
								var sourceID:String = String(input.@source).replace("#", "");
								if (sources.hasOwnProperty(sourceID))
								{
									//trace("Input: " +  input.@source);
									var inputObject:Object = new Object();
									inputObject.inputType = input.@semantic;
									inputObject.offset = input.@offset;
									inputObject.stride = sources[sourceID].stride;
									inputObject.values = sources[sourceID].values;
									
									if (input.@semantic == "VERTEX" || input.@semantic == "POSITION") inputObject.inputSize = 3;
									else if (input.@semantic == "NORMAL") inputObject.inputSize = 3;
									else if (input.@semantic == "TEXCOORD") inputObject.inputSize = 2;
									else inputObject.inputSize = 0;
									
									inputs.push(inputObject);
								}
                            }
                        }
						
                        pushVertex = function (vertIndex:int):void
                        {
                            vertIndex = vertIndex * inputLength;
							
                            for each (input in inputs) 
                            {
                                var inputValues:Vector.<Number> = input.values;
								//trace("inputValues: " + inputValues);
                                var stride:int = input.stride;
                                var offset:int = input.offset;
                                var vert:int = indices[vertIndex + offset] * stride;
								
                                if (offset == 0) 
                                {
                                    _daeIndices[surf].push(indices[vertIndex]);
                                }
								
                                if (input.inputType == Surface3D.COLOR0 || input.inputType == Surface3D.COLOR1) 
                                {
                                    surf.vertexVector.push(inputValues[vert], inputValues[vert + 1], inputValues[vert + 2]);
                                }
                                else if (input.inputSize == 3) 
                                {
                                    surf.vertexVector.push(inputValues[vert], inputValues[vert + 2], inputValues[vert + 1]);
									//trace(input.inputType + ": " + inputValues[vert] + "," + inputValues[vert + 2] + "," + inputValues[vert + 1]);
                                }
								else if (input.inputSize == 2)
								{
									surf.vertexVector.push(inputValues[vert], -inputValues[vert + 1]);
									//trace(input.inputType + ": " + inputValues[vert] + "," + -inputValues[vert + 1]);
								}
                            }
							
							//trace("VBuffer: " + surf.vertexVector);
                        }
						
                        var inputs:Vector.<Object> = new Vector.<Object>();
                        var surf:Surface3D = new Surface3D(node.@id);
						var indices:Vector.<uint> = new Vector.<uint>();
                        var colorSet:int = 0;
                        var uvSet:int = 0;
						
                        _daeSurfaces[surf] = tri.@material.toString();
						
						if (node.mesh.vertices.input.@semantic == "POSITION")
						{
							for each (var itemInput:XML in tri.input) 
							{
								if (itemInput.@semantic == "VERTEX")
								{
									itemInput.@semantic = "POSITION";
									itemInput.@source = node.mesh.vertices.input.@source;
								}
							}
						}
						
                        readInputs(tri.input);
                       
                        for each (var p:XML in tri.p) 
                        {
                            indices = indices.concat(Vector.<uint>(p.text().split(" ")));
							//trace("Primitive Polylist: " + indices);
                        }
						
                        var inputLength:int = 0;
                        
                        for each (var input:Object in inputs) 
                        {
							//trace("Input Type: " + input.inputType + ", Offset: " + input.offset + ", InputSize: " + input.inputSize);
							surf.addVertexData(input.inputType, input.inputSize);
							inputLength++;
                        }
                        
                        length = indices.length / inputLength;
                        _daeIndices[surf] = new Vector.<uint>();
						var count:int = 0;
						var index:int = 0;
						var tCount:int;
						var pIndex:int = 0;
						var e:int = 0;
						
						//trace("indicesLength: " + indices.length + ", inputLength: " + inputLength);
						
                        if (node.mesh.polylist == undefined) 
                        {
                            if (node.mesh.polygons == undefined) 
                            {
                                while (index < length) 
                                {
                                    pushVertex(index);
                                    surf.indexVector.unshift(index);
                                    ++index;
                                }
                            }
                            else 
                            {
								while (index < length) 
                                {
                                    pIndex = (pIndex + 1);
                                    count = int(tri.p[pIndex].text().split(" ").length) / inputLength;
                                    e = 1;
                                    while (e < count - 1) 
                                    {
                                        pushVertex(index + e + 1);
                                        pushVertex(index + e);
                                        pushVertex(index);
                                        tCount = (tCount + 1);
                                        tCount = (tCount + 1);
                                        tCount = (tCount + 1);
                                        surf.indexVector.push(tCount, tCount, tCount);
                                        ++e;
                                    }
                                    index = index + count;
                                }
                            }
                        }
                        else 
                        {
                            var vCount:Array = tri.vcount.text().split(" ");
							//trace("vCount: " + vCount);
							//trace("length: " + length);
                            while (index < length) 
                            {
								//pIndex = (pIndex + 1);
                                count = vCount[pIndex];
                                e = 1;
                                while (e < count - 1) 
                                {
                                    pushVertex(index + e + 1);
                                    pushVertex(index + e);
                                    pushVertex(index);
									
									//trace("pushVertex: " + Number(index + e + 1) + ", " + Number(index + e) + ", " + Number(index));
									e++;
									
                                    surf.indexVector.push(tCount++, tCount++, tCount++);
                                }
                                
								index += count;
								pIndex++;
								//trace("Surface Indices: " + surf.indexVector);
                            }
                        }
						
                        if (_flipNormals) Surface3DUtils.flipNormals(surf);
						
                        surfaces.push(surf);
						//trace("Surface Indices: " + surf.indexVector);
						//trace("Surface Verts: " + surf.vertexVector);
                    }
                }
            }
            return surfaces;
        }

        private function getMatrix(arg1:Array):Frame3D
        {
            var loc1:*=new Frame3D();
            loc1.copyColumnFrom(0, new Vector3D(arg1[0], arg1[2], arg1[1], arg1[3]));
            loc1.copyColumnFrom(2, new Vector3D(arg1[4], arg1[6], arg1[5], arg1[7]));
            loc1.copyColumnFrom(1, new Vector3D(arg1[8], arg1[10], arg1[9], arg1[11]));
            loc1.copyColumnFrom(3, new Vector3D(arg1[12], arg1[14], arg1[13], arg1[15]));
            loc1.transpose();
            return loc1;
        }

        private function get libraryContext():Library3D
        {
            if (_sceneContext) 
            {
                return _sceneContext.library;
            }
            if (scene) 
            {
                return scene.library;
            }
            return _library;
        }

        public function get request():*
        {
            return _request;
        }
    }
}


