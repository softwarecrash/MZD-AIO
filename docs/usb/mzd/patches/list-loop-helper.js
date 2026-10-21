// MZD-AIO: wrap only at the end of the complete enabled-item range.
List2Ctrl.prototype._aioWrapListFocus = function(direction, previousIndex)
{
    if (!this._hasFocus || this._inputMode !== 'controller' || this._inLetterIndexMulticontroller ||
        this._inListReorder || this._reorderTouchElt ||
        (!this.properties.scrollingDuringLoading && this._inLoading) ||
        previousIndex == null || previousIndex !== this._getFocussedIndex()) return false;

    var items = this.dataList && this.dataList.items;
    if (!items || items.length !== this.dataList.itemCount ||
        previousIndex < 0 || previousIndex >= items.length) return false;

    // A stationary focus at a viewport boundary still needs ordinary scrolling.
    var index = previousIndex + direction;
    while (index >= 0 && index < items.length)
    {
        if (!items[index] || !items[index].disabled) return false;
        index += direction;
    }

    index = direction > 0 ? 0 : items.length - 1;
    while (index >= 0 && index < items.length)
    {
        if (!items[index]) return false;
        if (!items[index].disabled)
        {
            this._manageFocus(index);
            return true;
        }
        index += direction;
    }
    return false;
};
