package jengine;

private class Vec2_Impl {
    public var x: Float;
    public var y: Float;

    public function new(x: Float = 0, y: Float = 0) {
        this.x = x;
        this.y = y;
    }

    public function length2() :Float {
        return x * x + y * y;
    }
    public function length() :Float {
        return Math.sqrt(length2());
    }
}

@:forward
abstract Vec2(Vec2_Impl) to Vec2_Impl from Vec2_Impl {
    public function new(x: Float = 0, y: Float = 0) {
        return new Vec2_Impl(x, y);
    }

    @:op(A + B) public static inline function add(lhs: Vec2, rhs :Vec2) :Vec2 {
        return new Vec2(lhs.x + rhs.x, lhs.y + rhs.y);
    }
    @:op(A - B) public static inline function sub(lhs: Vec2, rhs :Vec2) :Vec2 {
        return new Vec2(lhs.x - rhs.x, lhs.y - rhs.y);
    }

    @:op(A * B) @:commutative public static inline function scMult(lhs: Vec2, rhs :Float) :Vec2 {
        return new Vec2(lhs.x * rhs, lhs.y * rhs);
    }
    @:op(A / B) public static inline function scDiv(lhs: Vec2, rhs :Float) :Vec2 {
        return new Vec2(lhs.x / rhs, lhs.y / rhs);
    }

    @:op(A == B) public static inline function eq(lhs :Vec2, rhs :Vec2) {
        if (lhs == null && rhs == null) { return true; }
        if (lhs == null || rhs == null) { return false; }
        return lhs.x == rhs.x && lhs.y == rhs.y;
    }
    @:op(A != B) public static inline function neq(lhs :Vec2, rhs :Vec2) {
        return !(lhs == rhs);
    }

    public function dist(other :Vec2) :Float {
        return (other - this).length();
    }

    public static function max(lhs :Vec2, rhs :Vec2) :Vec2 {
        return new Vec2(Math.max(lhs.x, rhs.x),
            Math.max(lhs.y, rhs.y));
    }
    public static function min(lhs :Vec2, rhs :Vec2) :Vec2 {
        return new Vec2(Math.min(lhs.x, rhs.x),
            Math.min(lhs.y, rhs.y));
    }

    public static function unit(radians :Float) :Vec2 {
        return new Vec2(Math.cos(radians), Math.sin(radians));
    }

    public function angle() :Float {
        return Math.atan2(this.y, this.x);
    }

    public function rotate(ang :Float) :Vec2 {
        return unit(ang + angle()) * this.length();
    }
}
