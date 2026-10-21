/^List2Ctrl.prototype._handleMCCW = function\(\)/ {
    while ((getline line < helper) > 0) {print line; helperLines++;}
    close(helper);
    print "";
    helpers++;
}
/^List2Ctrl.prototype._handleMC(CW|CCW|Down|Up) = function\(\)/ {
    active=1;
    direction=($0 ~ /_(handleMCCW|handleMCDown) =/ ? 1 : -1);
    functions++;
}
{
    print;
    if (active && $0 ~ /^[ ]*var rfi = this\._getRelativeFocussedIndex\(\);$/) {
        match($0, /[^ ]/);
        indent=substr($0,1,RSTART-1);
        print indent "var aioPreviousIndex = this._getFocussedIndex();";
        captures++;
    }
    if (active && $0 ~ /^[ ]*rfi = this\._getRelativeFocussedIndex\(\);$/) {
        match($0, /[^ ]/);
        indent=substr($0,1,RSTART-1);
        print indent "if (this._aioWrapListFocus(" direction ", aioPreviousIndex)) return 'consumed';";
        calls++;
    }
    if ($0 ~ /^};$/) active=0;
}
END {if (helpers!=1 || helperLines<30 || functions!=4 || captures!=8 || calls!=4) exit 1;}
