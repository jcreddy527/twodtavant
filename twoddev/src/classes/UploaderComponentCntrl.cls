global class UploaderComponentCntrl {

    @AuraEnabled
    global static Id uploadFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        Attachment a = new Attachment();
        
        a.parentId = parentId;
       
        if (Schema.sObjectType.Attachment.fields.Body.isCreateable()){
        a.Body = EncodingUtil.base64Decode(base64Data);
        }
        if (Schema.sObjectType.Attachment.fields.Name.isCreateable()){
        a.Name = fileName;
        }
        if (Schema.sObjectType.Attachment.fields.ContentType.isCreateable()){
        a.ContentType = contentType;
        }
        try{
            insert a;
        }
        catch(DmlException e){
            return null;
        }


        return String.valueOf(a.Id);
    }

    @AuraEnabled
    global static Id uploadChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        if (fileId == '') {
            fileId = uploadFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }

        return Id.valueOf(fileId);
    }

    global static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = :fileId
        ];

        String existingBody = EncodingUtil.base64Encode(a.Body);
        if (Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.Body.isUpdateable()){
            a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        }
        
        if (Schema.sObjectType.Attachment.isUpdateable()) {
            update a;
        }
    }

    webService static void deleteAttachment(Id attachmentId){

        Attachment attachment=[select id from Attachment where id= :attachmentId limit 1];
         if (Schema.sObjectType.Attachment.isDeletable()) {
             delete attachment;
        }
    }
}