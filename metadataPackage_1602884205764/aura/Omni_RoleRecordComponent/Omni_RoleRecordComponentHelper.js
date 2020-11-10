({
    /**
     * @description cahgne tile's UI to indicate selection 
     * @author      Damian Kazior
     * @date        28/05/2020                    
     */
    changeUIOnSelect: function(component, vent, handler) {
        //console.log('selected');
        console.log('FIRED');
        if (component.get("v.selected")) {
            component.set("v.selected", false);
        } else {
            component.set("v.selected", true);
        }
    }
})