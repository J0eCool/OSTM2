package ostm.battle;

import js.*;
import js.html.*;

import jengine.*;
import jengine.util.Util;

class BattleRenderer extends Component {
    var _member :BattleMember;
    
    var _imageElem :ImageElement;
    var _nameEnt :Entity;
    var _hpBar :Entity;
    var _mpBar :Entity;
    var _attackBar :Entity;

    public function new(member :BattleMember) {
        _member = member;
    }

    public override function start() :Void {
        var renderer = getComponent(HtmlRenderer);
        var elem = renderer.getElement();
        var id = elem.id;
        var size = renderer.size;
        var nameSize = new Vec2(160, 30);
        var nameX = (size.x - nameSize.x) / 2;
        var barSize = new Vec2(160, 16);
        var barX = (size.x - barSize.x) / 2;
        var atkBarSize = new Vec2(180, 20);
        var atkBarX = (size.x - atkBarSize.x) / 2;

        _imageElem = Browser.document.createImageElement();
        _imageElem.src = 'img/' + _member.classType.image;
        _imageElem.height = Math.round(renderer.size.y);
        _imageElem.style.display = 'block';
        _imageElem.style.margin = '0px auto 0px auto';
        _imageElem.style.imageRendering = 'pixelated';
        elem.appendChild(_imageElem);

        _nameEnt = new Entity([
            new Transform(new Vec2(nameX, -62)),
            new HtmlRenderer({
                parent: id,
                size: nameSize,
                text: _member.classType.name,
                style: [
                    'background' => 'none',
                    'text-align' => 'center',
                ],
            }),
        ]);
        entity.getSystem().addEntity(_nameEnt);

        _hpBar = new Entity([
            new Transform(new Vec2(barX, -42)),
            new HtmlRenderer({
                parent: id,
                size: barSize,
                style: [
                    'background' => '#662222',
                    'border' => '2px solid black',
                ],
            }),
            new ProgressBar(function() {
                return _member.health / _member.maxHealth();
            }, [
                'background' => '#ff0000',
            ]),
        ]);
        _mpBar = new Entity([
            new Transform(new Vec2(barX, -24)),
            new HtmlRenderer({
                parent: id,
                size: barSize,
                style: [
                    'background' => '#222266',
                    'border' => '2px solid black',
                ],
            }),
            new ProgressBar(function() {
                return _member.mana / _member.maxMana();
            }, [
                'background' => '#0044ff',
            ]),
        ]);

        if (_member.isPlayer) {
            _hpBar.addComponent(new CenteredText(function() {
                return Util.format(_member.health) + ' / ' + Util.format(_member.maxHealth());
            }, 13));
            _mpBar.addComponent(new CenteredText(function() {
                return Util.format(_member.mana) + ' / ' + Util.format(_member.maxMana());
            }, 13));
        }
        entity.getSystem().addEntity(_hpBar);
        entity.getSystem().addEntity(_mpBar);

        _attackBar = new Entity([
            new Transform(new Vec2(atkBarX, 70)),
            new HtmlRenderer({
                parent: id,
                size: atkBarSize,
                style: [
                    'background' => '#226622',
                    'border' => '2px solid black',
                ],
            }),
            new ProgressBar(function() {
                return _member.attackSpeed() * _member.attackTimer;
            }, [
                'background' => '#00ff00',
            ]),
            new CenteredText(function() {
                return _member.curSkill.name;
            }),
        ]);
        entity.getSystem().addEntity(_attackBar);
    }
}
