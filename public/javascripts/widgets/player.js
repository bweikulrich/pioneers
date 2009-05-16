// Pioneers - web game based on the Settlers of Catan board game.

// Copyright (C) 2009 Jakub Kuźma <qoobaa@gmail.com>

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.

// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

$.widget("ui.player", {
    current: function(current) {
        if(current && !this.element.hasClass("current")) {
            this.element.addClass("current", 300);
        } else if (!current && this.element.hasClass("current")) {
            this.element.removeClass("current", 300);
        }
    },

    _init: function() {
        this.element.addClass("ui-widget ui-player");
        var playerDl = $("<dl/>").appendTo(this.element);

        $("<dt/>").appendTo(playerDl).text("Name");
        this.name = $("<dd/>").appendTo(playerDl).addClass("name");
        $("<dt/>").appendTo(playerDl).text("State");
        this.state = $("<dd/>").appendTo(playerDl).addClass("state");
        $("<dt/>").appendTo(playerDl).text("Resources");
        this.resources = $("<dd/>").appendTo(playerDl).addClass("resources");
        $("<dt/>").appendTo(playerDl).text("Cards");
        this.cards = $("<dd/>").appendTo(playerDl).addClass("cards");
        $("<dt/>").appendTo(playerDl).text("Points");
        this.points = $("<dd/>").appendTo(playerDl).addClass("points");

        this._refresh("name");
        this._refresh("resources");
        this._refresh("cards");
        this._refresh("points");
        this._refresh("state");
    },

    _refresh: function(key, highlight) {
        if(this[key]) {
            this[key].text(this.options[key]);
            if(highlight) this[key].effect("highlight");
        }
    },

    _setData: function(key, value) {
        if(this.options[key] !== value) {
            this._trigger(key + "change", null, [value]);
            this._trigger("change", null, {});
            this.options[key] = value;
            this._refresh(key, true);
        }
    },

    update: function(attributes) {
        var that = this;
        $.each(attributes, function(key, value) {
            that._setData(key, value);
        });
    }
});
