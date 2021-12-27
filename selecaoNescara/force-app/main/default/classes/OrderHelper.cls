public with sharing class OrderHelper {
    public OrderHelper() {}
    
    public static List<OrderItem> checkRecalcItem(Map<Id, Order> oldRecords, Map<Id, Order> newRecords ) {
        System.debug('checkRecalcItem.newRecords  ====>>>>    '+   newRecords);
        Set<Id> orderIds = new Set<Id>();
        
        for (Order order : newRecords.values()) {
            Order oldRecord = oldRecords.get(order.Id);

            if (order.DistributionCenter__c != oldRecord.DistributionCenter__c) {
                orderIds.add(order.Id);
            }
        }

        List<OrderItem> orderItemList = [
            SELECT Id, ListPrice, Product2Id, OrderId
            FROM OrderItem
            WHERE OrderId IN: orderIds
        ];
        
        List<OrderItem> updateOrderItemList = OrderItemHelper.calcPrice(orderItemList);

        return updateOrderItemList;
    }

    public static void getFreight(List<Order> newRecords) {
        System.debug('Estou no getFreight');
        Map<String, Freight__c> mapFretes = new Map<String, Freight__c>();
        
        List<Freight__c> listFretes = [
            SELECT Id, CEP__c, State__c, City__c, FreightByVolumn__c, FreightByWeight__c, FreightBase__c, DistributionCenter__c
            FROM Freight__c ];
            
        System.debug('listFretes ====>>>>  '+ listFretes);
        for (Freight__c item : listFretes) {
            System.debug('item frete ====>>>>   '+item);
            if (item.CEP__c != null) {
                mapFretes.put(item.CEP__c, item);                
            }
            if(item.City__c!=null){
                mapFretes.put(item.City__c, item);
            }
            if(item.State__c!=null){
                mapFretes.put(item.State__c, item);
            }
        }
        Set<Id> setOrders = new Set<Id>();
        for (Order item : newRecords) {          
            if (mapFretes.get(item.CEP__c)!=null) {
                item.Freight__c = mapFretes.get(item.CEP__c).Id;
                item.DistributionCenter__c = mapFretes.get(item.CEP__c).DistributionCenter__c;
            } else if(mapFretes.get(item.City__c)!=null) {
                item.Freight__c = mapFretes.get(item.City__c).Id;
                item.DistributionCenter__c = mapFretes.get(item.City__c).DistributionCenter__c;               
            } else if(mapFretes.get(item.State__c)!=null) {
                item.Freight__c = mapFretes.get(item.State__c).Id;
                item.DistributionCenter__c = mapFretes.get(item.State__c).DistributionCenter__c;                
            }
            setOrders.add(item.Id);
        }
        freightCalculation(setOrders, newRecords);
    }

    public static void freightCalculation(Set<Id> setOrders, List<Order> newRecords) {
        System.debug('Estou no freightCalculation');
        List<OrderItem> listOrderItems = [select Id, Product2.Name, OrderId, Quantity, Weight__c, Volume__c from OrderItem where OrderId IN : setOrders];
        for (Order itemOrder : newRecords) {
            System.debug('Estou no for de orders');
            Decimal amountQuantity = 0;
            Decimal amountWeight = 0;
            Decimal amountVolume = 0;
            for (OrderItem itemOrderItem : listOrderItems) {
                System.debug('Estou no for de orderItems');
                if(itemOrderItem.OrderId==itemOrder.Id){
                    if (itemOrderItem.Quantity!=null) {
                        amountQuantity += itemOrderItem.Quantity;
                    }
                    if (itemOrderItem.Weight__c!=null) {
                        amountWeight += itemOrderItem.Weight__c;
                    }
                    if (itemOrderItem.Volume__c!=null) {
                        amountVolume += itemOrderItem.Volume__c;
                    }
                }
            }
            Decimal calculationByVolume = 0;
            Decimal calculationByWeight = 0;
            Decimal calculationBase = 0;
            if (itemOrder.Freight__r.FreightByVolumn__c!=null) {
                calculationByVolume = amountVolume * itemOrder.Freight__r.FreightByVolumn__c;                
            }
            if (itemOrder.Freight__r.FreightByWeight__c!=null) {                
                calculationByWeight = amountWeight * itemOrder.Freight__r.FreightByWeight__c;
            }
            if (itemOrder.Freight__r.FreightBase__c!=null) {                
                calculationBase = amountQuantity * itemOrder.Freight__r.FreightBase__c;
            }

            if (calculationByVolume>calculationByWeight && calculationByVolume>calculationBase) {
                itemOrder.TotalFreight__c = calculationByVolume;
            } else if(calculationByWeight>calculationByVolume && calculationByWeight>calculationBase){
                itemOrder.TotalFreight__c = calculationByWeight;
            } else if(calculationBase>calculationByVolume && calculationBase>calculationByWeight){
                itemOrder.TotalFreight__c = calculationBase;
            }
        }

    }
}