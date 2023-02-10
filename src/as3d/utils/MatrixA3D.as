package as3d.utils 
{
	import flash.geom.Matrix3D;
	/**
	 * The MatrixA3D Class is a value object containing a 4x4 matrix used in 3D math, commonly representing affine transformations.
	 * 
	 * @author David Lenaerts
	 * 
	 */
	public class MatrixA3D
	{
		public var m11 : Number = 0, m12 : Number = 0, m13 : Number = 0, m14 : Number = 0;
		public var m21 : Number = 0, m22 : Number = 0, m23 : Number = 0, m24 : Number = 0;
		public var m31 : Number = 0, m32 : Number = 0, m33 : Number = 0, m34 : Number = 0;
		public var m41 : Number = 0, m42 : Number = 0, m43 : Number = 0, m44 : Number = 0;
		
		/**
		 * Creates a MatrixA3D object.
		 * 
		 * @param identity If true, the matrix will be initialized as an identity matrix. If false, it will be a null matrix.
		 */
		public function MatrixA3D(identity : Boolean = false)
		{
			if (identity) {
				this.identity();
			}
		}
		
		public function copyFromMatrix3D(mat:Matrix3D):void 
		{
			m11 = mat.rawData[0];
			m12 = mat.rawData[1];
			m13 = mat.rawData[2];
			m14 = mat.rawData[3];
			m21 = mat.rawData[4];
			m22 = mat.rawData[5];
			m23 = mat.rawData[6];
			m24 = mat.rawData[7];
			m31 = mat.rawData[8];
			m32 = mat.rawData[9];
			m33 = mat.rawData[10];
			m34 = mat.rawData[11];
			m41 = mat.rawData[12];
			m42 = mat.rawData[13];
			m43 = mat.rawData[14];
			m44 = mat.rawData[15];
		}
		
		/**
		 * A Number that determines whether a matrix is invertible.
		 * 
		 */
		public function get determinant3x3() : Number
		{
			return m11*(m22*m33-m23*m32)-m12*(m21*m33-m23*m31)+m13*(m21*m32-m22*m31);
		}
		
		
		/**
		 * An Array of 16 Numbers, where every four elements can be a row or a column of a 4x4 matrix.
		 */
		public function rawData() : Array
		{
			return new Array(	m11, m12, m13, m14,
								m21, m22, m23, m24,
								m31, m32, m33, m34,
								m41, m42, m43, m44);
		}
		
		/**
		 * Appends the matrix by multiplying another MatrixA3D object by the current MatrixA3D object.
		 */
		public function append(lhs : MatrixA3D) : void
		{
			var tempM11 : Number, tempM12 : Number, tempM13 : Number, tempM14 : Number;
			var tempM21 : Number, tempM22 : Number, tempM23 : Number, tempM24 : Number;
			var tempM31 : Number, tempM32 : Number, tempM33 : Number, tempM34 : Number;
			
			tempM11 = lhs.m11*m11 + lhs.m12*m21 + lhs.m13*m31 + lhs.m14*m41;
			tempM12 = lhs.m11*m12 + lhs.m12*m22 + lhs.m13*m32 + lhs.m14*m42;
			tempM13 = lhs.m11*m13 + lhs.m12*m23 + lhs.m13*m33 + lhs.m14*m43;
			tempM14 = lhs.m11*m14 + lhs.m12*m24 + lhs.m13*m34 + lhs.m14*m44;
			
			tempM21 = lhs.m21*lhs.m11 + lhs.m22*m21 + lhs.m23*m31 + lhs.m24*m41;
			tempM22 = lhs.m21*lhs.m12 + lhs.m22*m22 + lhs.m23*m32 + lhs.m24*m42;
			tempM23 = lhs.m21*lhs.m13 + lhs.m22*m23 + lhs.m23*m33 + lhs.m24*m43;
			tempM24 = lhs.m21*lhs.m14 + lhs.m22*m24 + lhs.m23*m34 + lhs.m24*m44;

			tempM31 = lhs.m31*lhs.m11 + lhs.m32*m21 + lhs.m33*m31 + lhs.m34*m41;
			tempM32 = lhs.m31*lhs.m12 + lhs.m32*m22 + lhs.m33*m32 + lhs.m34*m42;
			tempM33 = lhs.m31*lhs.m13 + lhs.m32*m23 + lhs.m33*m33 + lhs.m34*m43;
			tempM34 = lhs.m31*lhs.m14 + lhs.m32*m24 + lhs.m33*m34 + lhs.m34*m44;
			
			m11 = tempM11; m12 = tempM12; m13 = tempM13; m14 = tempM14;
			m21 = tempM21; m22 = tempM22; m23 = tempM23; m24 = tempM24;
			m31 = tempM31; m32 = tempM32; m33 = tempM33; m34 = tempM34;
			m41 = m42 = m43 = 0;
			m44 = 1;
		}
		
		/**
		 * Multiplies with a second matrix and returns the result as a new MatrixA3D.
		 * 
		 * @return The product of this matrix with another.
		 */
		public function multiply(rhs : MatrixA3D) : MatrixA3D
		{
			var matrix : MatrixA3D = new MatrixA3D();
			
			matrix.m11 = m11*rhs.m11 + m12*rhs.m21 + m13*rhs.m31 + m14*rhs.m41;
			matrix.m12 = m11*rhs.m12 + m12*rhs.m22 + m13*rhs.m32 + m14*rhs.m42;
			matrix.m13 = m11*rhs.m13 + m12*rhs.m23 + m13*rhs.m33 + m14*rhs.m43;
			matrix.m14 = m11*rhs.m14 + m12*rhs.m24 + m13*rhs.m34 + m14*rhs.m44;
			
			matrix.m21 = m21*rhs.m11 + m22*rhs.m21 + m23*rhs.m31 + m24*rhs.m41;
			matrix.m22 = m21*rhs.m12 + m22*rhs.m22 + m23*rhs.m32 + m24*rhs.m42;
			matrix.m23 = m21*rhs.m13 + m22*rhs.m23 + m23*rhs.m33 + m24*rhs.m43;
			matrix.m24 = m21*rhs.m14 + m22*rhs.m24 + m23*rhs.m34 + m24*rhs.m44;

			matrix.m31 = m31*rhs.m11 + m32*rhs.m21 + m33*rhs.m31 + m34*rhs.m41;
			matrix.m32 = m31*rhs.m12 + m32*rhs.m22 + m33*rhs.m32 + m34*rhs.m42;
			matrix.m33 = m31*rhs.m13 + m32*rhs.m23 + m33*rhs.m33 + m34*rhs.m43;
			matrix.m34 = m31*rhs.m14 + m32*rhs.m24 + m33*rhs.m34 + m34*rhs.m44;
			
			matrix.m41 = m41*rhs.m11 + m42*rhs.m21 + m43*rhs.m31 + m44*rhs.m41;
			matrix.m42 = m41*rhs.m12 + m42*rhs.m22 + m43*rhs.m32 + m44*rhs.m42;
			matrix.m43 = m41*rhs.m13 + m42*rhs.m23 + m43*rhs.m33 + m44*rhs.m43;
			
			matrix.m44 = 1;
			
			return matrix;
		}
		
		/**
		 * Multiplies with a second matrix, ignoring the last column and the last row, and returns the result as a new MatrixA3D.
		 * 
		 * @return The product of this matrix with another.
		 */
		public function multiply3x3(rhs : MatrixA3D) : MatrixA3D
		{
			var matrix : MatrixA3D = new MatrixA3D();
			
			matrix.m11 = m11*rhs.m11 + m12*rhs.m21 + m13*rhs.m31;
			matrix.m12 = m11*rhs.m12 + m12*rhs.m22 + m13*rhs.m32;
			matrix.m13 = m11*rhs.m13 + m12*rhs.m23 + m13*rhs.m33;
			
			matrix.m21 = m21*rhs.m11 + m22*rhs.m21 + m23*rhs.m31;
			matrix.m22 = m21*rhs.m12 + m22*rhs.m22 + m23*rhs.m32;
			matrix.m23 = m21*rhs.m13 + m22*rhs.m23 + m23*rhs.m33;

			matrix.m31 = m31*rhs.m11 + m32*rhs.m21 + m33*rhs.m31;
			matrix.m32 = m31*rhs.m12 + m32*rhs.m22 + m33*rhs.m32;
			matrix.m33 = m31*rhs.m13 + m32*rhs.m23 + m33*rhs.m33;
			
			return matrix;
		}
		/**
		 * Returns a new MatrixA3D object that is an exact copy of the current MatrixA3D object.
		 * 
		 * @return A duplicate of the current matrix.
		 */
		public function clone() : MatrixA3D
		{
			var matrix : MatrixA3D = new MatrixA3D();
			matrix.m11 = m11;
			matrix.m12 = m12;
			matrix.m13 = m13;
			matrix.m14 = m14;
			matrix.m21 = m21;
			matrix.m22 = m22;
			matrix.m23 = m23;
			matrix.m24 = m24;
			matrix.m31 = m31;
			matrix.m32 = m32;
			matrix.m33 = m33;
			matrix.m34 = m34;
			matrix.m41 = m41;
			matrix.m42 = m42;
			matrix.m43 = m43;
			matrix.m44 = m44;
			return matrix;
		}
		
		
		/**
		 * Uses the transformation matrix without its translation elements to transforms a VectorA3D object from one space coordinate to another.
		 * 
		 * @return The transformed vector. 
		 * 
		 * @see com.derschmale.wick3d.core.math.VectorA3D
		 */
		public function deltaTransformVector(v : VectorA3D) : VectorA3D
		{
			return new VectorA3D(m11*v.x + m12*v.y + m13*v.z,
								m21*v.x + m22*v.y + m23*v.z,
								m31*v.x + m32*v.y + m33*v.z);
		}
		
		
		/**
		 * Converts the current matrix to an identity or unit matrix.
		 */
		public function identity() : void
		{
			m11 = m22 = m33 = m44 = 1;
			m12 = m13 = m14 = m21 = m23 = m24 = m31 = m32 = m34 = m41 = m42 = m43 = 0;
		}

		/**
		 * Checks if the current matrix is an identity matrix.
		 * 
		 * @return A boolean value indicating whether the current matrix is an identity matrix.
		 * 
		 */
		public function isIdentity() : Boolean
		{
			return 	m11 == 1 && m12 == 0 && m13 == 0 && m14 == 0 &&
					m21 == 0 && m22 == 1 && m23 == 0 && m24 == 0 &&
					m31 == 0 && m32 == 0 && m33 == 1 && m34 == 0 &&
					m41 == 0 && m42 == 0 && m43 == 0 && m44 == 1;
		}
		
		/**
		 * Inverts the current matrix.
		 * 
		 * @return A boolean value indicating whether or not the matrix was invertible
		 * 
		 * @private
		 */
		public function invert():Boolean
		{
			// TO DO
			return false;
		}
	
		/**
		 * Returns a copy of the inverse of this matrix
		 * 
		 * @return The inverse of the current matrix.
		 */
		public function inverse() : MatrixA3D
		{
			var inv : MatrixA3D = new MatrixA3D();
			var detInv : Number = 1/determinant3x3;
			inv.m41 = inv.m42 = inv.m43 = 0;
			inv.m44 = 1;
			
			// 3x3 = M^-1
			// Tr: -M^-1 * T
			
			inv.m11 = (m22*m33-m23*m32)*detInv;
			inv.m12 = (m13*m32-m12*m33)*detInv;
			inv.m13 = (m12*m23-m13*m22)*detInv;
			inv.m21 = (m23*m31-m21*m33)*detInv;
			inv.m22 = (m11*m33-m13*m31)*detInv;
			inv.m23 = (m13*m21-m11*m23)*detInv;
			inv.m31 = (m21*m32-m22*m31)*detInv;
			inv.m32 = (m12*m31-m11*m32)*detInv;
			inv.m33 = (m11*m22-m12*m21)*detInv;
			
			inv.m14 = -inv.m11*m14-inv.m12*m24-inv.m13*m34;
			inv.m24 = -inv.m21*m14-inv.m22*m24-inv.m23*m34;
			inv.m34 = -inv.m31*m14-inv.m32*m24-inv.m33*m34;
			/* inv.m14 = -m14;
			inv.m24 = -m24;
			inv.m34 = -m34; */
			
			return inv;
		}
		
	 	/**
	 	 * Prepends a matrix by multiplying the current MatrixA3D object by another MatrixA3D object.
	 	 */
		public function prepend(rhs:MatrixA3D):void
		{
			var tempM11 : Number, tempM12 : Number, tempM13 : Number, tempM14 : Number;
			var tempM21 : Number, tempM22 : Number, tempM23 : Number, tempM24 : Number;
			var tempM31 : Number, tempM32 : Number, tempM33 : Number, tempM34 : Number;
			
			tempM11 = m11*rhs.m11 + m12*rhs.m21 + m13*rhs.m31 + m14*rhs.m41;
			tempM12 = m11*rhs.m12 + m12*rhs.m22 + m13*rhs.m32 + m14*rhs.m42;
			tempM13 = m11*rhs.m13 + m12*rhs.m23 + m13*rhs.m33 + m14*rhs.m43;
			tempM14 = m11*rhs.m14 + m12*rhs.m24 + m13*rhs.m34 + m14*rhs.m44;
			
			tempM21 = m21*rhs.m11 + m22*rhs.m21 + m23*rhs.m31 + m24*rhs.m41;
			tempM22 = m21*rhs.m12 + m22*rhs.m22 + m23*rhs.m32 + m24*rhs.m42;
			tempM23 = m21*rhs.m13 + m22*rhs.m23 + m23*rhs.m33 + m24*rhs.m43;
			tempM24 = m21*rhs.m14 + m22*rhs.m24 + m23*rhs.m34 + m24*rhs.m44;

			tempM31 = m31*rhs.m11 + m32*rhs.m21 + m33*rhs.m31 + m34*rhs.m41;
			tempM32 = m31*rhs.m12 + m32*rhs.m22 + m33*rhs.m32 + m34*rhs.m42;
			tempM33 = m31*rhs.m13 + m32*rhs.m23 + m33*rhs.m33 + m34*rhs.m43;
			tempM34 = m31*rhs.m14 + m32*rhs.m24 + m33*rhs.m34 + m34*rhs.m44;
					
			m11 = tempM11; m12 = tempM12; m13 = tempM13; m14 = tempM14;
			m21 = tempM21; m22 = tempM22; m23 = tempM23; m24 = tempM24;
			m31 = tempM31; m32 = tempM32; m33 = tempM33; m34 = tempM34;
			m41 = m42 = m43 = 0;
			m44 = 1;
		}
	 	 	
	
		/**
		 * Uses the transformation matrix to transform a VectorA3D object from one space coordinate to another.
		 * 
		 * @return The transformed VectorA3D.
		 * 
		 * @see com.derschmale.wick3d.core.math.VectorA3D
		 */
		public function transformVector(v:VectorA3D):VectorA3D
		{
			var product : VectorA3D = new VectorA3D();
			product.x = m11*v.x + m12*v.y + m13*v.z + m14*v.w;
			product.y = m21*v.x + m22*v.y + m23*v.z + m24*v.w;
			product.z = m31*v.x + m32*v.y + m33*v.z + m34*v.w;
			product.w = v.w;
			return product;
		}
		
		
		/**
		 * Converts the current MatrixA3D object to a matrix where the rows and columns are swapped.
		 */
		public function transpose() : void
		{
			var tempM12 : Number, tempM13 : Number, tempM14 : Number;
			var tempM21 : Number, tempM23 : Number, tempM24 : Number;
			var tempM31 : Number, tempM32 : Number, tempM34 : Number;
			var tempM41 : Number, tempM42 : Number, tempM43 : Number;
			
			tempM12 = m21;
			tempM13 = m31;
			tempM14 = m41;
			tempM21 = m12;
			tempM23 = m32;
			tempM24 = m42;
			tempM31 = m13;
			tempM32 = m23;
			tempM34 = m43;
			tempM41 = m14;
			tempM42 = m24;
			tempM43 = m34;
			
			m12 = tempM12;
			m13 = tempM13;
			m14 = tempM14;
			m21 = tempM21;
			m23 = tempM23;
			m24 = tempM24;
			m31 = tempM31;
			m32 = tempM32;
			m34 = tempM34;
			m41 = tempM41;
			m42 = tempM42;
			m43 = tempM43;
		}
		
		
		/**
		 * Generates a look at matrix; ie: a transformation matrix that will orient an object's coordinate system towards a target.
		 * 
		 * @param position The origin of the coordinate system to be transformed. Typically, this is an object's or camera's coordinates.
		 * @param target The point in 3D space toward which the coordinate system must be oriented.
		 * @param worldUp The world up vector in local space.
		 */
		public function createLookAt(position : VectorA3D, target : VectorA3D, worldUp : VectorA3D) : void
		{
			var angle : Number;
			var relUp : VectorA3D, temp : VectorA3D, dir : VectorA3D, right : VectorA3D;
			var len : Number;
			
			dir = target.subtract(position);
			dir.normalize();
			
			/* angle = worldUp.dotProduct(dir);
			temp = new VectorA3D(dir.x*angle, dir.y*angle, dir.z*angle);
			relUp = worldUp.subtract(temp);
			relUp.normalize(); */
			/* len = relUp.length;
			if (len != 0) {
				relUp.scaleBy(1/len);
			}
			else {
				// worldUp and relUp are the same
				relUp = worldUp;
			} */
			
			right = worldUp.crossProduct(dir);
			relUp = dir.crossProduct(right);
			
			m14 = m24 = m34 = 0;
			m44 = 1;
			
			m11 = right.x;
			m12 = right.y;
			m13 = right.z;
			m14 = -right.dotProduct(position);
			
			m21 = relUp.x;
			m22 = relUp.y;
			m23 = relUp.z;
			m24 = -relUp.dotProduct(position);
			
			m31 = dir.x;
			m32 = dir.y;
			m33 = dir.z;
			m34 = -dir.dotProduct(position);
		}
		
		/* public function createBase(front : VectorA3D, worldUp : VectorA3D) : void
		{
			var angle : Number;
			var relUp : VectorA3D, temp : VectorA3D;
			var right : VectorA3D;
			var len : Number;
			
			angle = worldUp.dotProduct(front);
			temp = new VectorA3D(front.x*angle, front.y*angle, front.z*angle);
			relUp = worldUp.subtract(temp);
			
			len = -relUp.length;
			
			if (len != 0) {
				relUp.scaleBy(1/len);
			}
			else {
				// worldUp and relUp are the same
				relUp = worldUp;
			} 
			
			right = relUp.crossProduct(front);
			
			m14 = m24 = m34 = 0;
			m44 = 1;
			
			m11 = right.x;
			m21 = right.y;
			m31 = right.z;
			m41 = 0;
			
			m12 = relUp.x;
			m22 = relUp.y;
			m32 = relUp.z;
			m42 = 0;
			
			m13 = front.x;
			m23 = front.y;
			m33 = front.z;
			m43 = 0;
		} */
		
		
		/**
		 * Creates a new Matrix that is the sum of the current matrix with another.
		 * 
		 * @return The sum of two matrices.
		 */
		public function add(a : MatrixA3D) : MatrixA3D
		{
			var m : MatrixA3D = new MatrixA3D();
			m.m11 = m11+a.m11;
			m.m12 = m12+a.m12;
			m.m13 = m13+a.m13;
			m.m14 = m14+a.m14;
			
			m.m21 = m21+a.m21;
			m.m22 = m22+a.m22;
			m.m23 = m23+a.m23;
			m.m24 = m24+a.m24;
			
			m.m31 = m31+a.m31;
			m.m32 = m32+a.m32;
			m.m33 = m33+a.m33;
			m.m34 = m34+a.m34;
			
			m.m41 = m41+a.m41;
			m.m42 = m42+a.m42;
			m.m43 = m43+a.m43;
			m.m44 = m44+a.m44;
			
			return m;
		}
		
		/**
		 * Creates a new Matrix that is the difference of the current matrix with another.
		 * 
		 * @return The difference of two matrices.
		 */
		public function subtract(a : MatrixA3D) : MatrixA3D
		{
			var m : MatrixA3D = new MatrixA3D();
			m.m11 = m11-a.m11;
			m.m12 = m12-a.m12;
			m.m13 = m13-a.m13;
			m.m14 = m14-a.m14;
			
			m.m21 = m21-a.m21;
			m.m22 = m22-a.m22;
			m.m23 = m23-a.m23;
			m.m24 = m24-a.m24;
			
			m.m31 = m31-a.m31;
			m.m32 = m32-a.m32;
			m.m33 = m33-a.m33;
			m.m34 = m34-a.m34;
			
			m.m41 = m41-a.m41;
			m.m42 = m42-a.m42;
			m.m43 = m43-a.m43;
			m.m44 = m44-a.m44;
			
			return m;
		}
		
		/**
		 * Adds another matrix to the current matrix.
		 */
		public function incrementBy(a : MatrixA3D) : void
		{
			m11 += a.m11;
			m12 += a.m12;
			m13 += a.m13;
			m14 += a.m14;
			
			m21 += a.m21;
			m22 += a.m22;
			m23 += a.m23;
			m24 += a.m24;
			
			m31 += a.m31;
			m32 += a.m32;
			m33 += a.m33;
			m34 += a.m34;
			
			m41 += a.m41;
			m42 += a.m42;
			m43 += a.m43;
			m44 += a.m44;
		}
		
		/**
		 * Decrements the current matrix with another matrix.
		 */
		public function decrementBy(a : MatrixA3D) : void
		{
			m11 -= a.m11;
			m12 -= a.m12;
			m13 -= a.m13;
			m14 -= a.m14;
			
			m21 -= a.m21;
			m22 -= a.m22;
			m23 -= a.m23;
			m24 -= a.m24;
			
			m31 -= a.m31;
			m32 -= a.m32;
			m33 -= a.m33;
			m34 -= a.m34;
			
			m41 -= a.m41;
			m42 -= a.m42;
			m43 -= a.m43;
			m44 -= a.m44;
		}
		
		/**
		 * Generates a matrix representing a rotation about the X-axis.
		 * 
		 * @param angle The angle of rotation in radians.
		 * 
		 * @return The rotation matrix.
		 */
		public static function xRotationMatrix(angle : Number) : MatrixA3D
		{
			var rot : MatrixA3D = new MatrixA3D();
			var cosAng : Number, sinAng : Number;
			cosAng = Math.cos(angle);
			sinAng = Math.sin(angle);

			rot.m11 = rot.m44 = 1;
			//rot.m12 = rot.m13 = rot.m14 = rot.m21 = rot.m31 = rot.m41 = rot.m42 = rot.m43 = rot.m24 = rot.m34 = 0;
			rot.m22 = cosAng;
			rot.m23 = -sinAng;
			rot.m32 = sinAng;
			rot.m33 = cosAng;

			return rot;
		}
	
		/**
		 * Generates a matrix representing a rotation about the Y-axis.
		 *
		 * @param angle The angle of rotation in radians.
		 *  
		 * @return The rotation matrix.
		 */
		public static function yRotationMatrix(angle : Number) : MatrixA3D
		{
			var rot : MatrixA3D = new MatrixA3D();
			var cosAng : Number, sinAng : Number;
			cosAng = Math.cos(angle);
			sinAng = Math.sin(angle);
			
			//rot.m14 = rot.m24 = rot.m34 = rot.m41 = rot.m42 = rot.m43 = rot.m12 = rot.m21 = rot.m23 = rot.m32 = 0;
			rot.m44 = rot.m22 = 1;
			rot.m11 = cosAng;
			rot.m13 = sinAng;
			rot.m31 = -sinAng;
			rot.m33 = cosAng;

			return rot;
		}
		
		/**
		 * Generates a matrix representing a rotation about the Z-axis.
		 * 
		 * @param angle The angle of rotation in radians.
		 * 
		 * @return The rotation matrix.
		 */
		public static function zRotationMatrix(angle : Number) : MatrixA3D
		{
			var rot : MatrixA3D = new MatrixA3D();
			var cosAng : Number, sinAng : Number;
			cosAng = Math.cos(angle);
			sinAng = Math.sin(angle);

			//rot.m14 = rot.m24 = rot.m34 = rot.m41 = rot.m42 = rot.m43 = rot.m13 = rot.m23 = rot.m31 = rot.m32 = 0;
			rot.m44 = rot.m33 = 1;
			rot.m11 = cosAng;
			rot.m12 = -sinAng;
			rot.m21 = sinAng;
			rot.m22 = cosAng;

			return rot;
		}
		
		/**
		 * Generates a matrix representing a rotation about the 3 coordinate axes.
		 * 
		 * @param x The angle of rotation in radians about the X-axis.
		 * @param y The angle of rotation in radians about the Y-axis.
		 * @param z The angle of rotation in radians about the Z-axis.
		 * 
		 * @return The rotation matrix.
		 */
		public static function rotationMatrix(x : Number, y : Number, z : Number) : MatrixA3D
		{
			var rot : MatrixA3D = new MatrixA3D();
			var cosX : Number = Math.cos(x);
			var sinX : Number = Math.sin(x);
			var cosY : Number = Math.cos(y);
			var sinY : Number = Math.sin(y);
			var cosZ : Number = Math.cos(z);
			var sinZ : Number = Math.sin(z);
			
			//rot.m14 = rot.m24 = rot.m34 = rot.m41 = rot.m42 = rot.m43 = 0;
			rot.m44 = 1;
			
			rot.m11 = cosY*cosZ;
			rot.m12 = -cosY*sinZ;
			rot.m13 = sinY;
			
			rot.m21 = sinX*sinY*cosZ+cosX*sinZ;
			rot.m22 = -sinX*sinY*sinZ+cosX*cosZ;
			rot.m23 = -sinX*cosY;
			
			rot.m31 = -cosX*sinY*cosZ+sinX*sinZ;
			rot.m32 = cosX*sinY*sinZ+sinX*cosZ;
			rot.m33 = cosX*cosY;
			
			return rot;
		}
		
		/**
		 * Generates a matrix representing a rotation about an arbitrary axis.
		 * 
		 * @param angle The angle of rotation in radians.
		 * @param axis The axis about which to rotate.
		 * 
		 * @return The rotation matrix.
		 */
		public static function axisRotationMatrix(angle : Number, axis : VectorA3D) : MatrixA3D
		{
			var rot : MatrixA3D = new MatrixA3D();
			var cos : Number = Math.cos(angle); 
			var sin : Number = Math.sin(angle);
			
			rot.m44 = 1;
			
			rot.m11 = cos+(1-cos)*axis.x*axis.x;
			rot.m12 = (1-cos)*axis.x*axis.y-sin*axis.z;
			rot.m13 = (1-cos)*axis.x*axis.z+sin*axis.y;
			
			rot.m21 = (1-cos)*axis.x*axis.y+sin*axis.z;
			rot.m22 = cos+(1-cos)*axis.y*axis.y;
			rot.m23 = (1-cos)*axis.y*axis.z-sin*axis.x
			
			rot.m31 = (1-cos)*axis.x*axis.z-sin*axis.y;
			rot.m32 = (1-cos)*axis.y*axis.z+sin*axis.x;
			rot.m33 = cos+(1-cos)*axis.z*axis.z;
			
			return rot;
		}
		
		
		/**
		 * Generates a matrix representing a rotation defined by Euler angles (strictly speaking: Tait-Bryan angles). As opposed to rotation about the coordinate axes, these values are independent of eachother.
		 * 
		 * @param pitch The angle of rotation around the X-axis
		 * @param yaw The angle of rotation around the Y-axis
		 * @param roll The angle of rotation around the Z-axis
		 * 
		 * @return The rotation matrix.
		 */
		public static function eulerMatrix(pitch : Number, yaw : Number, roll : Number) : MatrixA3D
		{
			var cosP : Number = Math.cos(-pitch);
			var cosY : Number = Math.cos(-yaw);
			var cosR : Number = Math.cos(roll);
			var sinP : Number = Math.sin(-pitch);
			var sinY : Number = Math.sin(-yaw);
			var sinR : Number = Math.sin(roll);
			var m : MatrixA3D = new MatrixA3D();
			
			var forwardVector : VectorA3D = new VectorA3D(-sinY*cosP, -sinP, cosY*cosP);
			var upVector : VectorA3D = new VectorA3D(-cosY*sinR-sinY*sinP*cosR, cosP*cosR, -sinY*sinR+sinP*cosR*cosY);
			var rightVector : VectorA3D = upVector.crossProduct(forwardVector);
			
			m.m44 = 1;
			
			m.m11 = rightVector.x;
			m.m21 = rightVector.y;
			m.m31 = rightVector.z;
			
			m.m12 = upVector.x;
			m.m22 = upVector.y;
			m.m32 = upVector.z;
			
			m.m13 = forwardVector.x;
			m.m23 = forwardVector.y;
			m.m33 = forwardVector.z;
			
			return m;
		}
		
		/**
		 * Generates a linear transformation matrix that represents a scaling transform.
		 * 
		 * @param x The scaling factor along the X-axis
		 * @param y The scaling factor along the Y-axis
		 * @param z The scaling factor along the Z-axis
		 * 
		 * @return The transformation matrix.
		 */
		public static function scaleMatrix(x : Number, y : Number, z : Number) : MatrixA3D
		{
			var matrix : MatrixA3D = new MatrixA3D();
			matrix.m11 = x;
			matrix.m22 = y;
			matrix.m33 = z;
			matrix.m44 = 1;
			return matrix;
		}
		
		/**
		 * Generates an affine transformation matrix that represents a translation.
		 * 
		 * @param x The displacement along the X-axis
		 * @param y The displacement along the Y-axis
		 * @param z The displacement along the Z-axis
		 * 
		 * @return The transformation matrix.
		 */
		public static function translationMatrix(x : Number, y : Number, z : Number) : MatrixA3D
		{
			var matrix : MatrixA3D = new MatrixA3D();
			matrix.m11 = matrix.m22 = matrix.m33 = matrix.m44 = 1;
			matrix.m41 = x;
			matrix.m42 = y;
			matrix.m43 = z;
			return matrix;
		}
		
		/**
		 * Generates a String representing the matrix' values
		 * 
		 * @return A String representing the matrix
		 */
		public function toString() : String
		{
			return 	"MatrixA3D:\n"+
					"( "+m11+" \t"+m12+" \t"+m13+" \t"+m14+" )\n"+
					"( "+m21+" \t"+m22+" \t"+m23+" \t"+m24+" )\n"+
					"( "+m31+" \t"+m32+" \t"+m33+" \t"+m34+" )\n"+
					"( "+m41+" \t"+m42+" \t"+m43+" \t"+m44+" )\n";
		}
	}
}