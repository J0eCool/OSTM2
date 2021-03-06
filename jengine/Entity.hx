package jengine;

@:allow(jengine.EntitySystem)
class Entity {
    var _components :Array<Component>;
    var _system :EntitySystem;
    var _hasStarted :Bool = false;

    public function new(components: Array<Component>) {
        _components = components;

        for (cmp in _components) {
            cmp.entity = this;
            cmp.init();
        }
    }

    public function addComponent(cmp :Component) :Void {
        _components.push(cmp);
        cmp.entity = this;
        cmp.init();
    }

    public function getComponent<T :Component>(c :Class<T>) :T {
        for (cmp in _components) {
            if (Std.is(cmp, c)) {
                return cast cmp;
            }
        }

        return null;
    }

    public inline function getTransform() :Transform {
        return getComponent(Transform);
    }

    public function getSystem() :EntitySystem {
        return _system;
    }
}
