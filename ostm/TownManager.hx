package ostm;

import js.*;
import js.html.*;

import jengine.*;
import jengine.util.Random;

import ostm.item.Inventory;
import ostm.item.Item;
import ostm.map.MapGenerator;
import ostm.map.MapNode;

class TownManager extends Component {
    var _wasInTown :Bool = false;
    var _shopItems = new Map<MapNode, Array<Item>>();

    public static var instance(default, null) :TownManager;

    public override function init() :Void {
        instance = this;
    }

    public override function update() :Void {
        var mapNode = MapGenerator.instance.selectedNode;
        var inTown = mapNode.isTown();
        Browser.document.getElementById('town-screen').style.display = inTown ? '' : 'none';

        if (inTown != _wasInTown) {
            _wasInTown = inTown;

            var shop = Browser.document.getElementById('town-shop');
            while (shop.childElementCount > 0) { 
                shop.removeChild(shop.firstChild);
            }
            _shopItems[mapNode] = [];

            var nItems = Random.randomIntRange(4, 6);
            for (i in 0...nItems) {
                var item = Inventory.instance.randomItem(mapNode.areaLevel());
                _shopItems[mapNode].push(item);

                shop.appendChild(item.createElement('li'));
            }
        }
    }
}