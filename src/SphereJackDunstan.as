package
{
	import flash.geom.Matrix3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.Context3D;
 
	/**
	* A procedurally-generated sphere
	* @author Jackson Dunstan
	*/
	public class SphereJackDunstan
	{
		/** Minimum number of horizontal slices any sphere can have */
		public static const MIN_SLICES:uint = 3;
 
		/** Minimum number of vertical stacks any sphere can have */
		public static const MIN_STACKS:uint = 3;
 
		/** Positions of the vertices of the sphere */
		public var positions:VertexBuffer3D;
 
		/** Texture coordinates of the vertices of the sphere */
		public var texCoords:VertexBuffer3D;
 
		/** Triangles of the sphere */
		public var tris:IndexBuffer3D;
 
		/** Matrix transforming the sphere from model space to world space */
		public var modelToWorld:Matrix3D;
 
		/**
		* Procedurally generate the sphere
		* @param context 3D context to generate the sphere in
		* @param slices Number of vertical slices around the sphere. Clamped to at least
		*               MIN_SLICES. Increasing this will increase the smoothness of the sphere at
		*               the cost of generating more vertices and triangles.
		* @param stacks Number of horizontal slices around the sphere. Clamped to at least
		*               MIN_STACKS. Increasing this will increase the smoothness of the sphere at
		*               the cost of generating more vertices and triangles.
		*/
		public function SphereJackDunstan(
			context:Context3D,
			slices:uint,
			stacks:uint,
			posX:Number=0, posY:Number=0, posZ:Number=0,
			scaleX:Number=1, scaleY:Number=1, scaleZ:Number=1
		)
		{
			// Make the model->world transformation matrix to position and scale the sphere
			modelToWorld = new Matrix3D(
				new <Number>[
					scaleX, 0,      0,      posX,
					0,      scaleY, 0,      posY,
					0,      0,      scaleZ, posZ,
					0,      0,      0,      1
				]
			);
 
			// Cap parameters
			if (slices < MIN_SLICES)
			{
				slices = MIN_SLICES;
			}
			if (stacks < MIN_STACKS)
			{
				stacks = MIN_STACKS;
			}
 
			// Data we will later upload to the GPU
			var positions:Vector.<Number>;
			var texCoords:Vector.<Number>;
			var tris:Vector.<uint>;
 
			// Pre-compute many constants used in tesselation
			const stepTheta:Number = (2.0*Math.PI) / slices;
			const stepPhi:Number = Math.PI / stacks;
			const stepU:Number = 1.0 / slices;
			const stepV:Number = 1.0 / stacks;
			const verticesPerStack:uint = slices + 1;
			const numVertices:uint = verticesPerStack * (stacks+1);
 
			// Allocate the vectors of data to tesselate into
			positions = new Vector.<Number>(numVertices*3);
			texCoords = new Vector.<Number>(numVertices*2);
			tris = new Vector.<uint>(slices*stacks*6);
 
			// Pre-compute half the sin/cos of thetas
			var halfCosThetas:Vector.<Number> = new Vector.<Number>(verticesPerStack);
			var halfSinThetas:Vector.<Number> = new Vector.<Number>(verticesPerStack);
			var curTheta:Number = 0;
			for (var slice:uint; slice < verticesPerStack; ++slice)
			{
				halfCosThetas[slice] = Math.cos(curTheta) * 0.5;
				halfSinThetas[slice] = Math.sin(curTheta) * 0.5;
				curTheta += stepTheta;
			}
 
			// Generate positions and texture coordinates
			var curV:Number = 1.0;
			var curPhi:Number = Math.PI;
			var posIndex:uint;
			var texCoordIndex:uint;
			for (var stack:uint = 0; stack < stacks+1; ++stack)
			{
				var curU:Number = 1.0;
				var curY:Number = Math.cos(curPhi) * 0.5;
				var sinCurPhi:Number = Math.sin(curPhi);
				for (slice = 0; slice < verticesPerStack; ++slice)
				{
					positions[posIndex++] = halfCosThetas[slice]*sinCurPhi;
					positions[posIndex++] = curY;
					positions[posIndex++] = halfSinThetas[slice] * sinCurPhi;
 
					texCoords[texCoordIndex++] = curU;
					texCoords[texCoordIndex++] = curV;
					curU -= stepU;
				}
 
				curV -= stepV;
				curPhi -= stepPhi;
			}
 
			// Generate tris
			var lastStackFirstVertexIndex:uint = 0;
			var curStackFirstVertexIndex:uint = verticesPerStack;
			var triIndex:uint;
			for (stack = 0; stack < stacks; ++stack)
			{
				for (slice = 0; slice < slices; ++slice)
				{
					// Bottom tri of the quad
					tris[triIndex++] = lastStackFirstVertexIndex + slice + 1;
					tris[triIndex++] = curStackFirstVertexIndex + slice;
					tris[triIndex++] = lastStackFirstVertexIndex + slice;
 
					// Top tri of the quad
					tris[triIndex++] = lastStackFirstVertexIndex + slice + 1;
					tris[triIndex++] = curStackFirstVertexIndex + slice + 1;
					tris[triIndex++] = curStackFirstVertexIndex + slice;
				}
 
				lastStackFirstVertexIndex += verticesPerStack;
				curStackFirstVertexIndex += verticesPerStack;
			}
 
			// Create vertex and index buffers
			this.positions = context.createVertexBuffer(positions.length/3, 3);
			this.positions.uploadFromVector(positions, 0, positions.length/3);
			this.texCoords = context.createVertexBuffer(texCoords.length/2, 2);
			this.texCoords.uploadFromVector(texCoords, 0, texCoords.length/2);
			this.tris = context.createIndexBuffer(tris.length);
			this.tris.uploadFromVector(tris, 0, tris.length);
		}
 
		public static function computeNumTris(slices:uint, stacks:uint): uint
		{
			if (slices < MIN_SLICES)
			{
				slices = MIN_SLICES;
			}
			if (stacks < MIN_STACKS)
			{
				stacks = MIN_STACKS;
			}
			return slices*stacks*6;
		}
 
		public function dispose(): void
		{
			this.positions.dispose();
			this.texCoords.dispose();
			this.tris.dispose();
		}
	}
}