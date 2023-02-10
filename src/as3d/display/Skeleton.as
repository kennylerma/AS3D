package as3d.display 
{
	import as3d.display.Bone;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import as3d.utils.Quaternion;
	import as3d.utils.VectorA3D;
	import as3d.utils.MatrixA3D;
	/**
	 * ...
	 * @author Kenny Lerma
	 */
	public class Skeleton 
	{
		private var _vertices:Vector.<Number>;
		private var _normals:Vector.<Number>;
		private var _posedVertices:Vector.<Number>;
		private var _posedNormals:Vector.<Number>;
		private var _bones:Vector.<Bone> = new Vector.<Bone>();
		private var _weights:Vector.<Number>;
		private var _bindShapeMatrix:Matrix3D;
		
		private var _curFrame:int = 0;
		private var _curLerp:int = 0;
		
		public var vcount:Vector.<Number>;
		public var v:Vector.<Number>;
		
		private var _animationTotalTime:Number = 30;
		private var _animationTime:Number = 0;
		private var _skeletonTotalFrames:Number = 3;
		
		public function Skeleton() 
		{
			
		}
		
		public function addBone(bone:Bone):void 
		{
			_bones.push(bone);
		}
		
		public function get bones():Vector.<Bone> { return _bones; }
		public function set bones(value:Vector.<Bone>):void { _bones = value; }
		public function set vertices(value:Vector.<Number>):void { _vertices = value; }
		public function set normals(value:Vector.<Number>):void { _normals = value; }
		public function get weights():Vector.<Number> { return _weights; }
		public function set weights(value:Vector.<Number>):void { _weights = value; }
		public function get bindShapeMatrix():Matrix3D { return _bindShapeMatrix; }
		public function set bindShapeMatrix(value:Matrix3D):void { _bindShapeMatrix = value; }
		
		public function get posedNormals():Vector.<Number> { return _posedNormals; }
		public function get posedVertices():Vector.<Number> { return _posedVertices; }
		
		public function gotoAndStop(frame:int):void 
		{
			//poseSkeleton(frame);
			poseSkeleton2(frame);
			poseModel();
			//poseModel2();
		}
		
		public function poseSkeleton(frame:int):void 
		{
			for each (var bone:Bone in _bones) 
			{
				// TODO frame smoothing by adding additional in-between keyframes?
				/*if (bone.frames.length > 0)
				{
					
				}*/
				
				var worldMatrix:Matrix3D = bone.frames[frame];
				
				//var quat:Quaternion = new Quaternion();
				//quat.fromMatrix(bone.frames[frame]);
				//trace("Orig Matrix: " + bone.frames[frame].rawData);
				//trace("pos: " + worldMatrix.position.x + ", " + worldMatrix.position.y + ", " + worldMatrix.position.z);
				//trace("quat: " + quat.x + ", " + quat.y + ", " + quat.z + "," + quat.w);
				
				
				
				//trace("Joint Mat: " + worldMatrix.rawData);
				if (bone.parentBone) worldMatrix.append(bone.parentBone.worldMatrix);
				bone.worldMatrix = worldMatrix;
				//trace("World Mat: " + worldMatrix.rawData);
				bone.inverseBindMatrix = worldMatrix.clone();
				bone.inverseBindMatrix.invert();
				bone.skinningMatrix = bone.inverseBindMatrix.clone();
				bone.skinningMatrix.append(worldMatrix);
				
				trace("offsetMatrix: " + bone.skinningMatrix.rawData);
				
				/*while(_curLerp > 1)
				{
					_curLerp -= 1.0;
					_curFrame++;
				}*/
				
				_curLerp = 0;
				_curFrame = 0;
				
				var nowFrame:Matrix3D = bone.frames[_curFrame % bone.frames.length];
				var nextFrame:Matrix3D = bone.frames[(_curFrame + 1) % bone.frames.length];
				/*var pwms = [];
				
				// For each bone in the keyframe
				for(var j = 0; j < kf.length; j++)
				{
					var bone = kf[j],                         // Bone j in the current frame
					bone1 = kf1[j],                           // Bone j in the next frame
					parent = this.geometry.bones[j].parent,   // Parent's number (same for both bones)
					worldMatrix = pwms[j] = mat4.create(),    // Calculated world matrix for bone j
					localMatrix = mat4.create(),              // Local matrix
					offsetMatrix = mat4.create(),             // Final matrix to apply to the weighted vertices
					lquat = quat.create(),
					lvec = vec3.create();
					
					// Spherical linear interpolation between the two bones' rotations,
					// Linear interpolation between the locations
					quat.slerp(lquat, bone.rot, bone1.rot, this.curLerp);
					vec3.lerp(lvec, bone.pos, bone1.pos, this.curLerp);
					
					mat4.fromRotationTranslation(localMatrix, lquat, lvec);
					
					// Again, worldMatrix = localMatrix if bone is root
					if(parent == -1)
					{
						mat4.copy(worldMatrix, localMatrix);
					} 
					else // ... or worldMatrix = parentWorldMatrix * localMatrix
					{ 
						mat4.multiply(worldMatrix, pwms[parent], localMatrix);
					}
					
					// Get the offset matrix = worldMatrix * bone's inverse bindpose
					mat4.multiply(offsetMatrix, worldMatrix, this.geometry.bones[j].inverseBindpose);
					//console.log("offsetMatrix: " + mat4.str(offsetMatrix));
					flat.push.apply(flat, offsetMatrix);
				}    */
			}
		}
		
		

		private function poseSkeleton2(frame:int):void
		{
			// Update the tree of bones
			for each (var bone:Bone in _bones) 
			{
				var worldMatrix:Matrix3D = bone.bindMatrix.clone();
				
				if (bone.frames.length > 0 && frame > 0)
				{
					if (frame > bone.frames.length - 1) throw new Error("Invalid Key frame");
					
					var InBetween:int = _animationTime * (_skeletonTotalFrames / _animationTotalTime);
					InBetween -= frame;
					
					if (frame < bone.frames.length - 1)
					{
					   var curFrame:Matrix3D = bone.frames[frame].clone();
					   var nextFrame:Matrix3D = bone.frames[frame + 1].clone();
					   curFrame.interpolateTo(nextFrame, InBetween);
						worldMatrix = curFrame;
					}
					else
					{
					   worldMatrix = bone.frames[frame];
					}
				}
				
				if (bone.parentBone) worldMatrix.append(bone.parentBone.worldMatrix);
				bone.worldMatrix = worldMatrix;
				var inverseBindMat:Matrix3D = bone.inverseBindMatrix.clone();
				inverseBindMat.append(worldMatrix);
				bone.skinningMatrix = inverseBindMat;
				
				/*// Handle its Children
				if (this->m_SkeletonData->m_Bones[CurrentBone]->HasChildren())
				{
					unsigned int NoOfChildren = this->m_SkeletonData->m_Bones[CurrentBone]->m_ChildCount;
					for (unsigned int Index = 0; Index < NoOfChildren; Index++)
					{
					   BonesStack.Push(this->m_SkeletonData->m_Bones[CurrentBone]->GetChildAt(Index));
					}
				}*/
			}
		}
		
		public function poseModel():void 
		{
			/*
			 The skinning calculation for each vertex v in a bind shape is
			 for i to n
				  v += {[(v * BSM) * skinningMatrix] * JW}
		 
			 • n: The number of joints that influence vertex v
			 • BSM: Bind-shape matrix
			 • IBMi: Inverse bind-pose matrix of joint i
			 • JMi: Transformation matrix of joint i
			 • JW: Weight of the influence of joint i on vertex v
		 
			 I have Got (v * BSM) and (IBMi * JMi) already multiplied since they are constants
			 */
			var vIndex:int;
			var vert:Vector3D;
			_posedVertices = new Vector.<Number>(_vertices.length);
			_posedNormals = new Vector.<Number>(_normals.length);
			
			for (var i:int = 0; i < vcount.length; i++) 
			{	
				var ix:int = i * 3;
				var iy:int = ix + 1;
				var iz:int = iy + 1;
				vert = new Vector3D(_vertices[ix], _vertices[iy], _vertices[iz]);
				trace("vert: " + vert.toString());
				
				var totalWeights:Number = 0;
				var boneInfluencesPerVertex:int = vcount[i];
				
				for (var l:int = 0; l < boneInfluencesPerVertex; l++) 
				{
					var boneIndex:int = v[vIndex++] 
					var boneWeightIndex:int = v[vIndex++];
					
					var bone:Bone = _bones[boneIndex];
					var weight:Number = _weights[boneWeightIndex];
					var skinningMatrix:Matrix3D = bone.skinningMatrix;
					//trace(bone.name + ", weight: " + weight);
					var vert2:Vector3D = skinningMatrix.transformVector(vert);
					
					/*var bindShapeMat:MatrixA3D = new MatrixA3D();
					bindShapeMat.copyFromMatrix3D(_bindShapeMatrix);
					var skinMat:MatrixA3D = new MatrixA3D();
					skinMat.copyFromMatrix3D(skinningMatrix);
					
					vert.multiplyMatrix(bindShapeMat);
					vert.multiplyMatrix(skinMat);*/
					
					_posedVertices[ix] += (vert2.x * weight);
					_posedVertices[iy] += (vert2.y * weight);
					_posedVertices[iz] += (vert2.z * weight);
					
					totalWeights += weight;
					trace(bone.name + " weight: " + weight);
				}
				
				trace("totalWeight: " + totalWeights);
				trace(" ");
			}
			
			trace("  orgin verts: " + _vertices);
			//trace("posedVertices: " + _posedVertices);
		}
		
		
		private function poseModel2():void
		{
			 /*
			 The skinning calculation for each vertex v in a bind shape is
			 for i to n
				  v += {[(v * BSM) * IBMi * JMi] * JW}
				
			 • n: The number of joints that influence vertex v
			 • BSM: Bind-shape matrix
			 • IBMi: Inverse bind-pose matrix of joint i
			 • JMi: Transformation matrix of joint i
			 • JW: Weight of the influence of joint i on vertex v
		 
			 I have Got (v * BSM) and (IBMi * JMi) already multiplied since they are constants
			 */
			 _posedVertices = new Vector.<Number>(_vertices.length);
			 _posedNormals = new Vector.<Number>(_normals.length);
			 var vIndex:int;
			 var NumberOfVertices:int = _vertices.length / 3;
			 
			 for (var CurrentVertex:int = 0; CurrentVertex < NumberOfVertices; CurrentVertex++) 
			 {
				var TempVertex:Vector3D = new Vector3D();
				var TempNormal:Vector3D = new Vector3D();
				var TempNormalTransform:Vector3D = new Vector3D();
				
				var Vertex:Vector3D = new Vector3D( _vertices[(CurrentVertex * 3)],
												  _vertices[(CurrentVertex * 3) + 1],
												  _vertices[(CurrentVertex * 3) + 2]);
				
				var Normal:Vector3D = new Vector3D( _normals[(CurrentVertex * 3)],
												  _normals[(CurrentVertex * 3) + 1],
												  _normals[(CurrentVertex * 3) + 2]);
				
				var TotalJointsWeight:Number = 0;
				var NormalizedWeight:Number = 0;
				
				var boneInfluencesPerVertex:int = vcount[CurrentVertex];
				for (var CurrentInfluence:int = 0; CurrentInfluence < boneInfluencesPerVertex; CurrentInfluence++)
				{
					var boneIndex:int = v[vIndex++] 
					var boneWeightIndex:int = v[vIndex++];
					
					var vertexBySkinMatrix:Vector3D = _bones[boneIndex].skinningMatrix.transformVector(Vertex);
					vertexBySkinMatrix.x = vertexBySkinMatrix.x * _weights[boneIndex];
					vertexBySkinMatrix.y = vertexBySkinMatrix.y * _weights[boneIndex];
					vertexBySkinMatrix.z = vertexBySkinMatrix.z * _weights[boneIndex];
					vertexBySkinMatrix.w = vertexBySkinMatrix.w * _weights[boneIndex];
					TempVertex.x += vertexBySkinMatrix.x;
					TempVertex.y += vertexBySkinMatrix.y;
					TempVertex.z += vertexBySkinMatrix.z;
					TempVertex.w += vertexBySkinMatrix.w;
					//TempVertex += ((Vertex * _bones[boneIndex].skinningMatrix) * _weights[boneWeightIndex]);
					
					/*TempVertex  += ((Vertex *
					   *this->m_SkeletonData->m_Bones[(*this->m_GeometryData->m_VertexInfluences)[CurrentVertex]->m_Joints[CurrentInfluence]]->m_SkinningMatrix) *
					   this->m_GeometryData->m_VertexWeightsArray[(*this->m_GeometryData->m_VertexInfluences)[CurrentVertex]->m_Weights[CurrentInfluence]]);*/
					
					
					var normalBySkinMatrix:Vector3D = _bones[boneIndex].skinningMatrix.transformVector(Normal);
					normalBySkinMatrix.x = normalBySkinMatrix.x * _weights[boneIndex];
					normalBySkinMatrix.y = normalBySkinMatrix.y * _weights[boneIndex];
					normalBySkinMatrix.z = normalBySkinMatrix.z * _weights[boneIndex];
					normalBySkinMatrix.w = normalBySkinMatrix.w * _weights[boneIndex];
					TempNormal.x += normalBySkinMatrix.x;
					TempNormal.y += normalBySkinMatrix.y;
					TempNormal.z += normalBySkinMatrix.z;
					TempNormal.w += normalBySkinMatrix.w;
					
					//_bones[boneIndex].skinningMatrix.transformVectors(Normal,TempNormalTransform);
					//TempNormal += TempNormalTransform * _weights[boneWeightIndex];
					
					TotalJointsWeight += _weights[boneWeightIndex];
				}
				
				if (TotalJointsWeight != 1)
				{
					NormalizedWeight = 1 / TotalJointsWeight;
					TempVertex.x *= NormalizedWeight;
					TempVertex.y *= NormalizedWeight;
					TempVertex.x *= NormalizedWeight;
					TempVertex.w *= NormalizedWeight;
					
					TempNormal.x *= NormalizedWeight;
					TempNormal.y *= NormalizedWeight;
					TempNormal.z *= NormalizedWeight;
					TempNormal.w *= NormalizedWeight;
				}
				
				_posedVertices[(CurrentVertex * 3)    ] = TempVertex.x;
				_posedVertices[(CurrentVertex * 3) + 1] = TempVertex.y;
				_posedVertices[(CurrentVertex * 3) + 2] = TempVertex.z;
				
				_posedNormals[(CurrentVertex * 3)    ] = TempNormal.x;
				_posedNormals[(CurrentVertex * 3) + 1] = TempNormal.y;
				_posedNormals[(CurrentVertex * 3) + 2] = TempNormal.z;
			}
		}
	}

}