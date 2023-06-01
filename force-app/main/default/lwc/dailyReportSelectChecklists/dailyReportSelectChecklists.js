/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, wire, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getChecklistTemplates from "@salesforce/apex/DailyReportSelectChecklistsController.getChecklistTemplates";
import createDailyReportItems from "@salesforce/apex/DailyReportSelectChecklistsController.createDailyReportItems";

export default class DailyReportSelectChecklists extends LightningElement {
  @api recordId;

  selectedChecklists = [];
  @track checklistOptions = [];

  loadingData = true;
  savingData = false;

  error;

  // # APEX

  // * GET ALL CHECKLIST TEMPLATES
  @wire(getChecklistTemplates, { dailyReportId: "$recordId" })
  wiredChecklists({ data, error }) {
    if (data) {
      console.log("data", data);

      for (const checklist of data) {
        this.checklistOptions.push({
          label: checklist.ozbee__Checklist_Type__c,
          value: checklist.Id
        });
      }
    } else if (error) {
      this.error = error.body.message ? error.body.message : error;
      this.showNotification("Error", this.error, "error");
    }

    setTimeout(() => {
      this.loadingData = false;
    }, 1000);
  }

  // * PASSES IN A LIST OF CHECKLIST TEMPLATE IDS TO CREATE CHECKLIST ITEMS
  createDailyReportItems() {
    this.savingData = true;

    createDailyReportItems({
      dailyReportId: this.recordId,
      checklistTemplateIdsString: JSON.stringify(
        Object.values(this.selectedChecklists)
      )
    })
      .then(() => {
        this.showNotification("Success", "Checklist items created", "success");
        this.error = null;
        this.closeModal();
      })
      .catch((error) => {
        this.error = error.body.message ? error.body.message : error;
        this.showNotification("Error", this.error, "error");
      })
      .finally(() => {
        this.savingData = false;
      });
  }

  // # HANDLERS

  // * HANDLES CHECKBOX CHANGE
  handleChangeChecklist(e) {
    this.selectedChecklists = e.detail.value;

    console.log(this.selectedChecklists);
  }

  // * CALLS APEX METHOD TO CREATE CHECKLIST ITEMS
  handleClickCreate() {
    this.createDailyReportItems();
  }

  // * HANDLES WHEN THE CLOSE BUTTON IS CLICKED
  handleClickClose() {
    this.closeModal();
  }

  // # PRIVATE FUNCTIONS

  // * CLOSES MODAL
  closeModal() {
    const closeQA = new CustomEvent("close");
    this.dispatchEvent(closeQA);
  }

  // * DISPLAY TOAST NOTIFICATION
  showNotification(title, message, variant, mode = "dismissable") {
    const toast = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(toast);
  }

  // # GETTERS

  // * DETERMINES IF THERE ARE ACTIVE CHECKLIST TEMPLATES
  get hasChecklistTemplates() {
    if (this.checklistOptions.length > 0) {
      return true;
    }
    return false;
  }

  // * ENABLES/DISABLES CREATE BUTTON IF A CHECKLIST IS SELECTED OR NOT
  get isCreateDisabled() {
    if (this.selectedChecklists.length === 0) {
      return true;
    }
    return false;
  }

  // * DISPLAY LOADING SPINNER
  get isLoading() {
    if (this.loadingData || this.savingData) {
      return true;
    }
    return false;
  }
}
