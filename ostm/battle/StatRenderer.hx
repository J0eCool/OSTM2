package ostm.battle;

import js.*;
import js.html.*;

import jengine.*;
import jengine.util.Util;

import ostm.item.Item;
import ostm.item.ItemType;
import ostm.skill.SkillTree;

class StatElement {
    var elem :Element;
    var title :String;
    var body :Void -> String;

    public function new(parent :Element, title :String, body :Void -> String) {
        elem = Browser.document.createElement('li');
        parent.appendChild(elem);

        this.title = title;
        this.body = body;
    }

    public function update() :Void {
        elem.innerText = title + ': ' + body();
    }
}

class StatRenderer extends Component {
    var _member :BattleMember;

    var _elements :Array<StatElement>;

    var _hpBar :Element;
    var _attackBar :Element;

    var _equipment = new Map<ItemSlot, Element>();
    var _cachedEquip = new Map<ItemSlot, Item>();

    public function new(member) {
        _member = member;
    }

    public override function start() :Void {
        var doc = Browser.document;
        var stats = doc.getElementById('stats');

        var nameSpan = doc.createSpanElement();
        nameSpan.innerText = _member.isPlayer ? 'Player:' : 'Enemy';
        stats.appendChild(nameSpan);

        var list = createAndAddTo('ul', stats);

        _elements = [
            new StatElement(list, 'Level', function() {
                return Util.format(_member.level);
            }),
            new StatElement(list, 'XP', function() {
                return Util.shortFormat(_member.xp) + ' / ' + Util.shortFormat(_member.xpToNextLevel());
            }),
            new StatElement(list, 'Gold', function() {
                return Util.shortFormat(_member.gold);
            }),
            new StatElement(list, 'Gems', function() {
                return Util.shortFormat(_member.gems);
            }),
            new StatElement(list, 'Health', function() {
                return Util.format(_member.health) + ' / ' + Util.format(_member.maxHealth());
            }),
            new StatElement(list, 'Mana', function() {
                return Util.format(_member.mana) + ' / ' + Util.format(_member.maxMana());
            }),
            new StatElement(list, 'Health Regen (in combat)', function() {
                return Util.formatFloat(_member.healthRegenInCombat()) + '/s';
            }),
            new StatElement(list, 'Health Regen (out of combat)', function() {
                return Util.formatFloat(_member.healthRegenOutOfCombat()) + '/s';
            }),
            new StatElement(list, 'Mana Regen', function() {
                return Util.formatFloat(_member.manaRegen()) + '/s';
            }),
            new StatElement(list, 'Damage', function() {
                return Util.format(_member.damage());
            }),
            new StatElement(list, 'Attack Speed', function() {
                return Util.formatFloat(_member.attackSpeed()) + '/s';
            }),
            new StatElement(list, 'Crit Rating', function() {
                var lev = BattleManager.instance.spawnLevel();
                return Util.format(_member.critInfo(lev).rating);
            }),
            new StatElement(list, 'Crit Chance', function() {
                var lev = BattleManager.instance.spawnLevel();
                return Util.formatFloat(100 * _member.critInfo(lev).chance) +
                    '% (against level ' + Util.format(lev) + ' enemies)';
            }),
            new StatElement(list, 'Crit Damage', function() {
                var lev = BattleManager.instance.spawnLevel();
                return '+' + Util.formatFloat(100 * _member.critInfo(lev).damage, 0) + '%';
            }),
            new StatElement(list, 'Armor', function() {
                return Util.format(_member.defense());
            }),
            new StatElement(list, 'Damage Reduction', function() {
                var lev = BattleManager.instance.spawnLevel();
                return Util.formatFloat(_member.damageReduction(lev) * 100) +
                    '% (against level ' + Util.format(lev) + ' enemies)';
            }),
            new StatElement(list, 'Move Speed', function() {
                return '+' + Util.formatFloat(100 * (_member.moveSpeed() - 1), 0) + '%';
            }),
            new StatElement(list, 'Hunting', function() {
                return Util.format(_member.huntSkill());
            }),
            new StatElement(list, 'Enemy spawn time', function() {
                return Util.formatFloat(BattleManager.instance.enemySpawnTime()) + 's';
            }),
            new StatElement(list, 'STR', function() {
                return Util.format(_member.strength());
            }),
            new StatElement(list, 'DEX', function() {
                return Util.format(_member.dexterity());
            }),
            new StatElement(list, 'INT', function() {
                return Util.format(_member.intelligence());
            }),
            new StatElement(list, 'VIT', function() {
                return Util.format(_member.vitality());
            }),
            new StatElement(list, 'END', function() {
                return Util.format(_member.endurance());
            }),
            new StatElement(list, 'Power', function() {
                return Util.formatFloat(_member.power());
            }),
            new StatElement(list, 'DPS', function() {
                return Util.formatFloat(_member.dps());
            }),
            new StatElement(list, 'EHP', function() {
                return Util.formatFloat(_member.ehp());
            }),
        ];

        if (_member.isPlayer) {
            var equipTab = doc.getElementById('equip-screen');
            for (k in _member.equipment.keys()) {
                var slot = createAndAddTo('span', equipTab);
                slot.className = ('equip-slot').toLowerCase();
                _equipment[k] = slot;
                updateEquipSlot(k);
            }
        }
    }

    function createAndAddTo(tag :String, parent :Element) {
        var elem = Browser.document.createElement(tag);
        parent.appendChild(elem);
        return elem;
    }

    public override function update() :Void {
        for (stat in _elements) {
            stat.update();
        }
        if (_member.isPlayer) {
            for (k in _equipment.keys()) {
                var item = _member.equipment[k];
                if (_cachedEquip[k] != item) {
                    _cachedEquip[k] = item;
                    updateEquipSlot(k);
                }
            }
        }
    }

    function updateEquipSlot(slot :ItemSlot) :Void {
        var item = _member.equipment[slot];
        var elem = _equipment[slot];
        while (elem.childElementCount > 0) {
            elem.removeChild(elem.firstChild);
        }
        
        if (item != null) {
            elem.appendChild(item.createElement([
                'Unequip' => function(event) {
                    item.unequip();
                },
            ]));
        }
    }
}
