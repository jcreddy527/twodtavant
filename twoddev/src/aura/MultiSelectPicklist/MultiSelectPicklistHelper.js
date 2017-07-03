({
	changeindexposition : function (old_index, new_index,strarray) {
    if (new_index >= strarray.length) {
        var k = new_index - strarray.length;
        while ((k--) + 1) {
            strarray.push(undefined);
        }
    }
    strarray.splice(new_index, 0, strarray.splice(old_index, 1)[0]);
    return strarray; // for testing purposes
}
})