/*
Copyright (c) 2008 David Lenaerts.  See:
    http://code.google.com/p/wick3d
    http://www.derschmale.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package as3d.utils
{
	/**
	 * 
	 * The VectorA3D class represents a point or a direction in 3D space.
	 * 
	 * @author David Lenaerts
	 * 
	 */
	public class VectorA3D
	{
		/**
		 * The absolute x-axis
		 */
		public static const XAXIS : VectorA3D = new VectorA3D(1, 0, 0);
		
		/**
		 * The absolute y-axis
		 */
		public static const YAXIS : VectorA3D = new VectorA3D(0, 1, 0);
		
		/**
		 * The absolute z-axis
		 */
		public static const ZAXIS : VectorA3D = new VectorA3D(0, 0, 1);
		
		/**
		 * The x-coordinate of the vector
		 */
		public var x : Number;
		
		/**
		 * The y-coordinate of the vector
		 */
		public var y : Number;
		
		/**
		 * The z-coordinate of the vector
		 */
		public var z : Number;
		
		/**
		 * A number defining whether the vector is a direction vector (0) or a point (1). Points are translated, whereas Vectors aren't.
		 */
		public var w : Number;
		
		/**
		 * Creates a new VectorA3D object.
		 * 
		 * @param x The x-coordinate of the vector
		 * @param y The y-coordinate of the vector
		 * @param z The z-coordinate of the vector
		 * @param w A number defining whether the vector is a direction vector (0) or a point (1)
		 */
		public function VectorA3D(x : Number = 0, y : Number = 0, z : Number = 0, w : Number = 0)
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.w = w;
		}
		
		/**
		 * The length of the vector, or the distance from a point to the origin.
		 */
		public function get length() : Number
		{
			return Math.sqrt(x*x + y*y + z*z);
		}
		
		/**
		 * The squared length of the vector, or the squared distance from a point to the origin.
		 */
		public function get lengthSquared() : Number
		{
			return x*x + y*y + z*z;
		}
		
		/**
		 * Adds a vector to the current vector, and returns the result as new instance.
		 * 
		 * @return The sum of two vectors.
		 */
		public function add(a : VectorA3D) : VectorA3D
		{
			return new VectorA3D(a.x+x, a.y+y, a.z+z, w);
		}
		
		/**
		 * Calculates the angle between two vectors.
		 * 
		 * @return The angle between two vectors.
		 */
		public function angleBetween(a : VectorA3D) : Number
		{
			return Math.acos(dotProduct(a)/(length*a.length));
		}
		
		/**
		 * Creates a new vector that is an exact duplicate of the current.
		 * 
		 * @return A clone of the current vector.
		 */
		public function clone() : VectorA3D
		{
			return new VectorA3D(x, y, z, w);
		}
		
		/**
		 * Calculates the cross product of two vectors
		 * 
		 * @return The cross product of two vectors.
		 */
		public function crossProduct(a : VectorA3D) : VectorA3D
		{
			return new VectorA3D(y*a.z - z*a.y, z*a.x - x*a.z, x*a.y - y*a.x);
		}
		
		/**
		 * Deducts a vector from the current one.
		 */
		public function decrementBy(a : VectorA3D) : void
		{
			x -= a.x;
			y -= a.y;
			z -= a.z;
		}
		
		/**
		 * Calculates the distance between two points.
		 * 
		 * @returns The distance between two points.
		 */
		public static function distance(a : VectorA3D, b : VectorA3D) : Number
		{
			return Math.sqrt((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y) + (a.z - b.z)*(a.z - b.z)); 
		}
		
		/**
		 * Calculates the dot product of two vectors
		 * 
		 * @return The dot product of two vectors.
		 */
		public function dotProduct(a : VectorA3D) : Number
		{
			return x*a.x+y*a.y+z*a.z;
		}
		
		/**
		 * Compares two vectors to see if they are equal.
		 * 
		 * @param toCompare The vector to compare with the current.
		 * @param allFour Defines if the w-coordinate should be used in the comparison.
		 * 
		 * @return Whether or not the vectors are equal.
		 */		
		public function equals(toCompare : VectorA3D, allFour : Boolean = false) : Boolean
		{
			return 	(x == toCompare.x) &&
					(y == toCompare.y) &&
					(z == toCompare.z) &&
					((w == toCompare.w) || !allFour); 
		}
		
		/**
		 * Compares two vectors to see if they are equal within a margin of error.
		 * 
		 * @param toCompare The vector to compare with the current.
		 * @param tolerance The maximum difference that each component is allowed to have to be considered equal.
		 * @param allFour Defines if the w-coordinate should be used in the comparison.
		 * 
		 * @return Whether or not the vectors are quasi equal.
		 */		
		public function nearEquals(toCompare : VectorA3D, tolerance : Number = 0.0001, allFour : Boolean = false) : Boolean
		{
			if (Math.abs(toCompare.x - x) > tolerance) return false; 
			if (Math.abs(toCompare.y - y) > tolerance) return false;
			if (Math.abs(toCompare.z - z) > tolerance) return false;
			if (!allFour) return true;
			if (Math.abs(toCompare.w - w) > tolerance) return false;
			return true
		}
		
		/**
		 * Adds a vector to the current vector.
		 */
		public function incrementBy(a : VectorA3D) : void
		{
			x += a.x;
			y += a.y;
			z += a.z;
		}
		
		/**
		 * Negates the current vector.
		 */
		public function negate() : void
		{
			x = -x;
			y = -y;
			z = -z;
		}
		
		/**
		 * Scales the vector so it becomes unit length.
		 */
		public function normalize() : void
		{
			var invLength : Number = 1/Math.sqrt(x*x + y*y + z*z);
			x *= invLength;
			y *= invLength;
			z *= invLength;
		}
		
		/**
		 * Divides the x, y and z coordinates by the w-component.
		 */
		public function project() : void
		{
			var wInv : Number = 1/w;
			x *= wInv;
			y *= wInv;
			z *= wInv;
		}
		
		/**
		 * Multiplies the vector by a scalar value
		 */
		public function scaleBy(s : Number) : void
		{
			x *= s;
			y *= s;
			z *= s;
		}
		
		/**
		 * Deducts two vectors and returns the result as a new vector.
		 * 
		 * @return The difference between to vectors.
		 */
		public function subtract(a : VectorA3D) : VectorA3D
		{
			return new VectorA3D(x-a.x, y-a.y, z-a.z);
		}
		
		/**
		 * Generates a string representation of the coordinates of the vector.
		 * 
		 * @return A String representation of the vector.
		 */
		public function toString() : String
		{
			return "VectorA3D("+x+", "+y+" ,"+z+")";
		}
		
		/**
		 * Multiplies this vector with a matrix;
		 */
		public function multiplyMatrix(m : MatrixA3D) : void
		{
			var xO : Number = x;
			var yO : Number = y;
			var zO : Number = z;
			
			x = xO*m.m11+yO*m.m12+zO*m.m13+m.m14;
			y = xO*m.m21+yO*m.m22+zO*m.m23+m.m24;
			z = xO*m.m31+yO*m.m32+zO*m.m33+m.m34;
		}
	}
}