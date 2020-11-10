public without sharing class Omni_Utils{
	private static String kHexChars = '0123456789abcdef';

    
    /**
    * @description Retrieve query string including all the object fields
    * @author      Luis Merinero
    * @date        20/12/2019                     
    */
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
        if (whereClause == null || whereClause == ''){ return null; }
         
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fieldsMap != null){
            for (Schema.SObjectField ft : fieldsMap.values()){
                Schema.DescribeFieldResult fd = ft.getDescribe();
				selectFields.add(fd.getName());
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
        }
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
    }

    /**
    * @description Retrieve query string including all the object fields with additional reference fields
    *              API names of additional fields need to be seperated with comma
    * @author      Luis Merinero
    * @date        20/12/2019                     
    */
    public static string getCreatableFieldsSOQL(String objectName, String whereClause, String additionalFields){
         
        String selects = '';
        if (whereClause == null || whereClause == ''){ return null; }
         
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fieldsMap != null){
            for (Schema.SObjectField ft : fieldsMap.values()){
                Schema.DescribeFieldResult fd = ft.getDescribe();
				selectFields.add(fd.getName());
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
        }
        if (String.isBlank(additionalFields)) {
            return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
        } else {
            return 'SELECT ' + selects + ', ' + additionalFields +' FROM ' + objectName + ' WHERE ' + whereClause;
        }
    }
    
 public static String NewGuid() {

        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {

            if (i==4 || i==6 || i==8 || i==10) 
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }

   public static String getCharAtIndex(String str, Integer index) {

        if (str == null) return null;

        if (str.length() <= 0) return str;    

        if (index == str.length()) return null;    

        return str.substring(index, index+1);
    }
}