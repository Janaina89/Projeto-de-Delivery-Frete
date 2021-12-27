trigger OrderTrigger on Order (before insert, after insert, before update, after update) {
OrderTriggerHandler handler = new OrderTriggerHandler(
    Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap
);

switch on Trigger.operationType {
    when AFTER_UPDATE {
        handler.afterUpdate();
    }when BEFORE_UPDATE{
        handler.beforeUpdate();
    }
  }
}