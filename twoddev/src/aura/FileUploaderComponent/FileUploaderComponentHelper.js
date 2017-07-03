({
    MAX_FILE_SIZE: 1000000,
    /* 6 000 000 * 3/4 to account for base64 */
    CHUNK_SIZE: 950 000,
    /* Use a multiple of 4 */

    save: function(component, file, fileContents,helper) {
      var self = this;
      var fileInput;

      if (component.get("v.show")) {
        fileInput = component.find("file").getElement();
      } else {
        fileInput = component.find("fileUp").getElement();

      }

      var files = fileInput.files;

      //run a loop for each chosen file to be uploaded
      for (var i = 0; i < files.length; i++) {
        file = files[i];
		console.log('=====MAX_FILE_SIZE========='+this.MAX_FILE_SIZE);
        if (file.size > this.MAX_FILE_SIZE) {
          alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
            'Selected file size: ' + file.size);
          return;
        }

        var fileReader = new FileReader();
        var self = this;


        fileReader.onloadend = (function(file) {

          return function() {

            var fileContents = fileReader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);

            if (component.get("v.show")) {
              component.find("saveButton").set("v.disabled", true);
              document.getElementById("saveButtonHider1").style.display="none";
            } else {
              component.find("saveButtonGenericElement").set("v.disabled", true);
            }

            self.upload(component, file, fileContents);
          }

        })(file);

        fileReader.readAsDataURL(file);
      }
    },
    visible : function(component,Element) {
  									var pageElement = component.find(Element);
  									console.log(pageElement);
                   $A.util.addClass(pageElement, 'slds-show');
  								 $A.util.removeClass(pageElement, 'slds-hide');
  	},
  	invisible: function(component,Element){
  									 var pageElement = component.find(Element);
  									 console.log(pageElement);
                     $A.util.removeClass(pageElement, 'slds-show');
  									 $A.util.addClass(pageElement, 'slds-hide');
  	},

    upload: function(component, file, fileContents) {
      var fromPos = 0;
      console.log(file);
      var toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);

      // start with the initial chunk

      this.uploadChunk(component, file, fileContents, fromPos, toPos, '');
      return status;
    },

    uploadChunk: function(component, file, fileContents, fromPos, toPos, attachId) {
      var action = component.get("c.uploadChunk");
      var chunk = fileContents.substring(fromPos, toPos);
      console.log(file);
      action.setParams({
        parentId: component.get("v.parentId"),
        fileName: file.name,
        base64Data: encodeURIComponent(chunk),
        contentType: file.type,
        fileId: attachId
      });

      var self = this;

      action.setCallback(this, function(response) {
        attachId = response.getReturnValue();

        if (component.get("v.show")) {
          component.find("saveButton").set("v.disabled", false);

        } else {
          component.find("saveButtonGenericElement").set("v.disabled", false);
        }

        this.readAndUpdateAllAttachments(component);

        fromPos = toPos;
        toPos = Math.min(fileContents.length, fromPos + self.CHUNK_SIZE);

        if (fromPos < toPos) {
          self.uploadChunk(component, file, fileContents, fromPos, toPos, attachId);
        }

      });

      $A.enqueueAction(action);
    },

    readAndUpdateAllAttachments: function(component) {
      var arrayOfAttachments;

      var actionReadAttachments1 = component.get("c.ReadSObjects");
      var parentId = component.get("v.parentId");
      var query = "SELECT Id, IsDeleted, ParentId, Name, IsPrivate, ContentType,BodyLength, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Description FROM Attachment";
      query += " where parentId='" + parentId + "'";
      actionReadAttachments1.setParams({
        query: query
      });
      actionReadAttachments1.setCallback(this, function(response) {

        if (response.getState() == 'SUCCESS') {
          arrayOfAttachments = response.getReturnValue().sObjList;


          if (component.get("v.show") == false) {
            component.set("v.totalAttachments", arrayOfAttachments.length);
          } else {
              
                  for(var i=0;i<arrayOfAttachments.length;i++){
                	arrayOfAttachments[i].BodyLength = Math.round(  ( (arrayOfAttachments[i].BodyLength / 1024)*100)/100   );
                    console.log(arrayOfAttachments[i].BodyLength);
                  }
              
            component.set("v.attachments", arrayOfAttachments);
          }
        }

      });
      $A.enqueueAction(actionReadAttachments1);

    },

    deleteAttachment: function(component,helper) {
      var selectedItem = event.currentTarget;
      var id = selectedItem.dataset.record;
      var actionReadAttachment = component.get("c.ReadSObjects");
      var query = "SELECT Id FROM Attachment";
      query += " where Id='" + id + "'";

      actionReadAttachment.setParams({
        query: query
      });
      actionReadAttachment.setCallback(this, function(response) {

        if (response.getState() == 'SUCCESS') {
          var attachment = response.getReturnValue().sObjList;

          var actionDeleteAttachment = component.get("c.DeleteSObjects");

          actionDeleteAttachment.setParams({
            inputSObjectList: attachment
          });
          actionDeleteAttachment.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
              this.readAndUpdateAllAttachments(component);
            }
            helper.invisible(component,'SpinnerDiv');
            helper.visible(component,'filesTable');
          });

          $A.enqueueAction(actionDeleteAttachment);
        }
      });
      $A.enqueueAction(actionReadAttachment);

    }

  }

)