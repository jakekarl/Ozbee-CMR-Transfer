import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createProductionScheduleItems from "@salesforce/apex/GenerateProductionScheduleController.createProductionScheduleItems";

export default class GenerateProductionSchedule extends LightningElement {
  @api recordId;

  @api invoke() {
    this.showNotification(
      "Generating Scheduling...",
      "Please wait while the production schedule is being generated",
      "warning"
    );

    this.createProductionScheduleItems();
  }

  // # APEX

  createProductionScheduleItems() {
    createProductionScheduleItems({ productionJobId: this.recordId })
      .then(() => {
        this.showNotification(
          "Success",
          "Production schedule has been generated",
          "success"
        );
      })
      .catch((error) => {
        console.log("error", error);
        this.showNotification("Error", error.body.message, "error");
      });
  }

  // # PRIVATE METHODS
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
}
