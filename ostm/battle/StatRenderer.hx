package ostm.battle;

import js.*;
import js.html.*;

import jengine.*;

import ostm.item.Item;
import ostm.item.ItemType;

class StatRenderer extends Component {
    var _member :BattleMember;

    var _level :Element;
    var _xp :Element;
    var _hp :Element;
    var _damage :Element;
    var _defense :Element;

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
        _level = createAndAddTo('li', list);
        _xp = createAndAddTo('li', list);
        _hp = createAndAddTo('li', list);
        _damage = createAndAddTo('li', list);
        _defense = createAndAddTo('li', list);

        if (_member.isPlayer) {
            var equip = createAndAddTo('ul', stats);
            for (k in _member.equipment.keys()) {
                _equipment[k] = createAndAddTo('li', equip);
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
        _level.innerText = 'Level: ' + _member.level;
        _xp.innerText = 'XP: ' + _member.xp + ' / ' + _member.xpToNextLevel();
        _hp.innerText = 'HP: ' + _member.health + ' / ' + _member.maxHealth();
        _damage.innerText = 'Damage: ' + _member.damage();
        _defense.innerText = 'Defense: ' + _member.defense();

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
        
        var slotName = Browser.document.createSpanElement();
        slotName.innerText = slot + ': ';
        elem.appendChild(slotName);

        if (item == null) {
            var nullItem = Browser.document.createSpanElement();
            nullItem.innerText = '(none)';
            nullItem.style.fontStyle = 'italic';
            elem.appendChild(nullItem);
        }
        else {
            elem.appendChild(item.createElement('ul', true));
        }
    }
}
