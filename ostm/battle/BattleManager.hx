package ostm.battle;

import js.html.*;

import jengine.*;

class BattleMember {
    public var entity :Entity;
    public var elem :Element;
    public var isPlayer :Bool = false;

    public var maxHealth :Int;
    public var healthRegen :Float;
    public var attackSpeed :Float;

    public var health :Int;
    public var healthPartial :Float = 0;
    public var attackTimer :Float = 0;

    public function new(entity :Entity) {
        this.entity = entity;
    }
}

class BattleManager extends Component {
    var _player :BattleMember;
    var _enemy :BattleMember;
    var _battleMembers :Array<BattleMember> = [];

    var _enemySpawnTimer :Float = 0;
    static inline var kEnemySpawnTime :Float = 4;
    var _isPlayerDead :Bool = false;

    public override function start() :Void {
        _player = addBattleMember(new Vec2(50, 300));
        _player.elem.style.background = '#0088ff';
        _enemy = addBattleMember(new Vec2(300, 300));

        _player.isPlayer = true;
        _player.maxHealth = 100;
        _player.attackSpeed = 1.2;
        _player.healthRegen = 2.5;

        _enemy.maxHealth = 50;
        _enemy.attackSpeed = 0.9;
        
        for (mem in _battleMembers) {
            mem.health = mem.maxHealth;
        }
    }

    public override function update() :Void {
        var hasEnemySpawned = _enemySpawnTimer >= kEnemySpawnTime && !_isPlayerDead;
        _enemy.elem.style.display = hasEnemySpawned ? '' : 'none';
        if (!hasEnemySpawned) {
            _enemySpawnTimer += Time.dt;

            _player.healthPartial += _player.healthRegen * Time.dt;
            var dHealth = Math.floor(_player.healthPartial);
            _player.health += dHealth;
            _player.healthPartial -= dHealth;
            if (_player.health >= _player.maxHealth) {
                _player.health = _player.maxHealth;

                if (_isPlayerDead) {
                    _isPlayerDead = false;
                    _enemySpawnTimer = 0;
                }
            }

            return;
        }

        for (mem in _battleMembers) {
            mem.attackTimer += Time.dt;
            var attackTime = 1.0 / mem.attackSpeed;
            if (mem.attackTimer > attackTime) {
                mem.attackTimer -= attackTime;
                if (mem.isPlayer) {
                    dealDamage(_enemy, 5);
                }
                else {
                    dealDamage(_player, 5);
                }
            }
        }
    }

    function dealDamage(target :BattleMember, damage :Int) :Void {
        target.health -= damage;
        if (target.health <= 0) {
            target.health = 0;
            for (mem in _battleMembers) {
                if (!mem.isPlayer) {
                    mem.health = mem.maxHealth;
                }
                mem.attackTimer = 0;
            }
            _enemySpawnTimer = 0;

            if (target.isPlayer) {
                _isPlayerDead = true;
            }
        }
    }

    function addBattleMember(pos :Vec2) :BattleMember {
        var id = 'battle-member-' + _battleMembers.length;
        var size = new Vec2(60, 60);
        var barSize = new Vec2(150, 20);
        var barX = (size.x - barSize.x) / 2;
        var system = entity.getSystem();
        var ent = new Entity([
            new Transform(pos),
            new HtmlRenderer({
                id: id,
                parent: 'battle-screen',
                size: size,
            }),
        ]);
        system.addEntity(ent);

        var bat = new BattleMember(ent);
        bat.elem = ent.getComponent(HtmlRenderer).getElement();

        var hpBar = new Entity([
            new Transform(new Vec2(barX, -60)),
            new HtmlRenderer({
                parent: id,
                size: barSize,
                style: [
                    'background' => 'none',
                    'border' => '2px solid black',
                ],
            }),
            new ProgressBar(function() {
                return bat.health / bat.maxHealth;
            }, [
                'background' => '#ff0000',
            ]),
        ]);
        system.addEntity(hpBar);
        var attackBar = new Entity([
            new Transform(new Vec2(barX, -38)),
            new HtmlRenderer({
                parent: id,
                size: barSize,
                style: [
                    'background' => 'none',
                    'border' => '2px solid black',
                ],
            }),
            new ProgressBar(function() {
                return bat.attackSpeed * bat.attackTimer;
            }, [
                'background' => '#00ff00',
            ]),
        ]);
        system.addEntity(attackBar);

        _battleMembers.push(bat);
        return bat;
    }
}