public with sharing class OrderTriggerHandler {

    List<Order> oldRecords {get ; set;} // Trigeer.old
    List<Order> newRecords {get ; set;} // Trigeer.new
    Map<Id, Order> oldMap {get; set;} // Trigger.oldMap
    Map<Id, Order> newMap {get; set;} // Trigger.newMap

    public OrderTriggerHandler( List<Order> oldRecords, List<Order> newRecords, Map<Id, Order> oldMap, Map<Id, Order> newMap) {
        System.debug('newRecords  ====>>>  '+newRecords);
        this.oldRecords = oldRecords;
        this.newRecords = newRecords;
        this.oldMap = oldMap;
        this.newMap = newMap;
    }

    public void afterUpdate() {
        List<OrderItem> updateOrderItemList = OrderHelper.checkRecalcItem(this.oldMap, this.newMap);
        update updateOrderItemList;
    }

    public void beforeUpdate(){
        System.debug('this.newRecords  ====>>>>   '+this.newRecords);
        OrderHelper.getFreight(this.newRecords);
    }

}