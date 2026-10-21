# Exact insertions from the original AIO list-loop payload; no new JS logic.
/^List2Ctrl.prototype._handleMC(CW|CCW|Down|Up) = function\(\)/ {name=$0; n=0; functions++;}
{
    if (name!="") n++;
    print;
    if (name=="List2Ctrl.prototype._handleMCCW = function()" && n==61) {
        if ($0!="") exit 1;
        print "            var currentFocussedIndex = this._getFocussedIndex();";
        print "";
        insertions++;
    }
    if (name=="List2Ctrl.prototype._handleMCCW = function()" && n==80) {
        if ($0!="            rfi = this._getRelativeFocussedIndex();") exit 1;
        print "";
        print "            if (this._getFocussedIndex() == currentFocussedIndex) //didn't move";
        print "            {";
        print "                if (this.dataList && this.dataList.items)";
        print "                {";
        print "                    var index = 0;";
        print "                    while (index < this.dataList.items.length && this.dataList.items[index].disabled) index++;";
        print "                    if (index < this.dataList.items.length)";
        print "                    {";
        print "                        this._manageFocus(index);";
        print "                        return 'consumed';";
        print "                    }";
        print "                }";
        print "            }";
        insertions++;
    }
    if (name=="List2Ctrl.prototype._handleMCCCW = function()" && n==56) {
        if ($0!="") exit 1;
        print "            var currentFocussedIndex = this._getFocussedIndex();";
        print "";
        insertions++;
    }
    if (name=="List2Ctrl.prototype._handleMCCCW = function()" && n==75) {
        if ($0!="            rfi = this._getRelativeFocussedIndex();") exit 1;
        print "";
        print "            if (this._getFocussedIndex() == currentFocussedIndex) //didn't move";
        print "            {";
        print "                if (this.dataList && this.dataList.items)";
        print "                {";
        print "                    var index = this.dataList.items.length - 1;";
        print "                    while (index >= 0 && this.dataList.items[index].disabled) index--;";
        print "                    if (index >= 0)";
        print "                    {";
        print "                        this._manageFocus(index);";
        print "                        return 'consumed';";
        print "                    }";
        print "                }";
        print "            }";
        insertions++;
    }
    if (name=="List2Ctrl.prototype._handleMCDown = function()" && n==52) {
        if ($0!="") exit 1;
        print "                var currentFocussedIndex = this._getFocussedIndex();";
        print "";
        insertions++;
    }
    if (name=="List2Ctrl.prototype._handleMCDown = function()" && n==71) {
        if ($0!="                rfi = this._getRelativeFocussedIndex();") exit 1;
        print "";
        print "                if (this._getFocussedIndex() == currentFocussedIndex) //didn't move";
        print "                {";
        print "                    if (this.dataList && this.dataList.items)";
        print "                    {";
        print "                        var index = 0;";
        print "                        while (index < this.dataList.items.length && this.dataList.items[index].disabled) index++;";
        print "                        if (index < this.dataList.items.length)";
        print "                        {";
        print "                            this._manageFocus(index);";
        print "                            return 'consumed';";
        print "                        }";
        print "                    }";
        print "                }";
        insertions++;
    }
    if (name=="List2Ctrl.prototype._handleMCUp = function()" && n==46) {
        if ($0!="") exit 1;
        print "                var currentFocussedIndex = this._getFocussedIndex();";
        print "";
        insertions++;
    }
    if (name=="List2Ctrl.prototype._handleMCUp = function()" && n==65) {
        if ($0!="                rfi = this._getRelativeFocussedIndex();") exit 1;
        print "";
        print "                if (this._getFocussedIndex() == currentFocussedIndex) //didn't move";
        print "                {";
        print "                    if (this.dataList && this.dataList.items)";
        print "                    {";
        print "                        var index = this.dataList.items.length - 1;";
        print "                        while (index >= 0 && this.dataList.items[index].disabled) index--;";
        print "                        if (index >= 0)";
        print "                        {";
        print "                            this._manageFocus(index);";
        print "                            return 'consumed';";
        print "                        }";
        print "                    }";
        print "                }";
        insertions++;
    }
    if ($0 ~ /^};$/) name="";
}
END {if (functions!=4 || insertions!=8) exit 1;}
