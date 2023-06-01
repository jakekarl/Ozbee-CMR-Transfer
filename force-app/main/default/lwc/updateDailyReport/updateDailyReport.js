import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getDailyReportData from "@salesforce/apex/UpdateDailyReportController.getDailyReportData";
import updateDailyReportItems from "@salesforce/apex/UpdateDailyReportController.updateDailyReportItems";
import updateDailyExpectedProductions from "@salesforce/apex/UpdateDailyReportController.updateDailyExpectedProductions";

export default class UpdateDailyReport extends LightningElement {
  @api recordId;

  wiredData;

  @track dailyReportData = {};
  projectPhotos = [];

  selectedCategory;
  @track selectedDailyReportItem;

  loadingData = true;
  savingData = false;

  error;

  renderedCallback() {
    if (this.selectedDailyReportItem?.ozbee__Daily_Report_Photos__r) {
      for (const reportPhoto of this.selectedDailyReportItem
        .ozbee__Daily_Report_Photos__r) {
        let photoDiv = this.template.querySelector(
          '[data-photo-id="' + reportPhoto.Company_Cam_Photo_Id__c + '"]'
        );
        photoDiv.classList.add("photo-selected");
      }
    }
  }

  connectedCallback() {
    console.log("connected");
    console.log("recordId", this.recordId);
    // refreshApex(this.wiredData);
    this.getDailyReportData();
  }

  // # APEX

  // * RETRIEVES DAILY REPORT, DAILY REPORT ITEMS AND EXPECTED PRODUCTION ITEMS
  getDailyReportData() {
    getDailyReportData({ dailyReportId: this.recordId })
      .then((data) => {
        console.log("DAILY REPORT DATA", data);

        data = JSON.parse(JSON.stringify(data));

        console.log(
          "DAILY REPORT :::",
          JSON.parse(JSON.stringify(data.dailyReport))
        );

        for (const dailyReportItem of data.dailyReportItems) {
          let category = dailyReportItem.Checklist__c;

          Object.defineProperty(dailyReportItem, "numberOfPhotos", {
            get: function () {
              return this.ozbee__Daily_Report_Photos__r
                ? this.ozbee__Daily_Report_Photos__r.length
                : 0;
            }
          });

          if (category in this.dailyReportData) {
            this.dailyReportData[category].items.push(dailyReportItem);
          } else {
            this.dailyReportData[category] = {
              title: category,
              items: [dailyReportItem],
              showTitle: true,
              showItems: false,
              isDailyReportItem: true
            };
          }
        }

        this.dailyReportData = {
          ...this.dailyReportData,
          "Expected Production": {
            title: "Expected Production",
            items: [
              ...data.dailyExpectedProduction.map((production) => {
                production.ExpectedTotalLabel =
                  "Expected (" + production.Measurement__c + ")";
                production.PreviouslyCompletedLabel = "Previously Completed";
                production.CompletedTodayLabel = "Completed Today";
                return production;
              })
            ],
            showTitle: true,
            showItems: false,
            isExpectedProduction: true
          }
        };

        this.projectPhotos = data.projectPhotos;

        // console.log("DAILY REPORT DATA :::", JSON.parse(JSON.stringify(this.dailyReportData)));
        // console.log("PROJECT PHOTOS :::", JSON.parse(JSON.stringify(this.projectPhotos)));
        this.error = null;
      })
      .catch((error) => {
        console.log("error", error);
        this.showError(error.body.message);

        this.error = error;
      })
      .finally(() => {
        this.loadingData = false;
      });
  }

  // @wire(getDailyReportData, { dailyReportId: "$recordId" })
  // wiredDailyReportData(value) {
  // 	this.wiredData = value;

  // 	let { data, error } = value;
  // 	if (data) {
  // 		console.log("WIRED DAILY REPORT DATA", data);

  // 		data = JSON.parse(JSON.stringify(data));

  // 		console.log("DAILY REPORT :::", JSON.parse(JSON.stringify(data.dailyReport)));

  // 		for (const dailyReportItem of data.dailyReportItems) {
  // 			let category = dailyReportItem.Checklist__c;

  // 			Object.defineProperty(dailyReportItem, "numberOfPhotos", {
  // 				get: function () {
  // 					return this.ozbee__Daily_Report_Photos__r ? this.ozbee__Daily_Report_Photos__r.length : 0;
  // 				}
  // 			});

  // 			if (category in this.dailyReportData) {
  // 				this.dailyReportData[category].items.push(dailyReportItem);
  // 			} else {
  // 				this.dailyReportData[category] = {
  // 					title: category,
  // 					items: [dailyReportItem],
  // 					showTitle: true,
  // 					showItems: false,
  // 					isDailyReportItem: true
  // 				};
  // 			}
  // 		}

  // 		this.dailyReportData = {
  // 			...this.dailyReportData,
  // 			"Expected Production": {
  // 				title: "Expected Production",
  // 				items: [
  // 					...data.dailyExpectedProduction.map((i) => {
  // 						i.ExpectedLabel = "Expected (" + i.Measurement__c + ")";
  // 						i.CompletedLabel = "Completed (" + i.Measurement__c + ")";
  // 						return i;
  // 					})
  // 				],
  // 				showTitle: true,
  // 				showItems: false,
  // 				isExpectedProduction: true
  // 			}
  // 		};

  // 		this.projectPhotos = data.projectPhotos;

  // 		console.log("DAILY REPORT DATA :::", JSON.parse(JSON.stringify(this.dailyReportData)));
  // 		// console.log("PROJECT PHOTOS :::", JSON.parse(JSON.stringify(this.projectPhotos)));
  // 		this.error = null;

  // 		this.loadingData = false;
  // 	} else if (error) {
  // 		console.log("error", error);
  // 		this.showError(error.body.message);

  // 		this.error = error;
  // 		this.loadingData = false;
  // 	}
  // }

  // * SAVES CHANGES TO DAILY REPORT ITEMS
  updateDailyReportItems(dailyReportItems) {
    this.savingData = true;

    let dailyReportItemsToUpdate = [];
    let dailyReportPhotosToInsert = [];

    for (const reportItem of dailyReportItems) {
      // console.log("REPORT ITEM :::", JSON.parse(JSON.stringify(reportItem)));

      if (!reportItem.ozbee__Daily_Report_Photos__r) {
        reportItem.ozbee__Daily_Report_Photos__r = [];
      }

      let { ozbee__Daily_Report_Photos__r, ...rest } = reportItem;

      dailyReportItemsToUpdate.push(rest);

      let photos = ozbee__Daily_Report_Photos__r.map((p) => {
        // eslint-disable-next-line no-unused-vars
        let { Id, ...other } = p;
        return other;
      });

      if (ozbee__Daily_Report_Photos__r) {
        dailyReportPhotosToInsert.push(...photos);
      }
    }

    updateDailyReportItems({
      dailyReportItemsString: JSON.stringify(dailyReportItemsToUpdate),
      dailyReportPhotosString: JSON.stringify(dailyReportPhotosToInsert)
    })
      .then(() => {
        this.showSuccess("Daily Report Items Saved");
      })
      .catch((error) => {
        console.log("error", error);
        this.showNotification(
          "Error Saving Daily Report Items",
          error,
          "error"
        );
      })
      .finally(() => {
        this.savingData = false;
      });
  }

  // * SAVES CHAGNES TO DIALY EXPECTED PRODUCTIONS
  updateDailyExpectedProductions(dailyExpectedProductions) {
    this.savingData = true;

    updateDailyExpectedProductions({
      dailyExpectedProductionsString: JSON.stringify(dailyExpectedProductions)
    })
      .then(() => {
        this.showSuccess("Expected Production Saved");
      })
      .catch((error) => {
        console.log("error", error);
        this.showNotification(
          "Error Saving Expected Production",
          error.body.message,
          "error"
        );
      })
      .finally(() => {
        this.savingData = false;
      });
  }

  // # HANDLERS

  // * HANDLES WHEN A CATEGORY IS CLICKED
  handleClickCategory(event) {
    for (const category of Object.values(this.dailyReportData)) {
      if (category.title === event.currentTarget.dataset.category) {
        category.showTitle = true;
        category.showItems = true;
      } else {
        category.showTitle = false;
        category.showItems = false;
      }
    }

    this.selectedCategory = event.currentTarget.dataset.category;
  }

  // * HANDLE CHANGE FORM VALUE
  handleChangeValue(event) {
    let value = event.currentTarget.value;
    let itemId = event.currentTarget.dataset.itemId;
    let category = event.currentTarget.dataset.category;
    let field = event.currentTarget.dataset.field;

    let currentItem = this.dailyReportData[category].items.find(
      (item) => item.Id === itemId
    );
    currentItem[field] = value;
  }

  // * HANDLES WHEN THE ATTACHMENT ICON IS CLICKED
  handleClickPhotoSelector(event) {
    let itemId = event.currentTarget.dataset.itemId;

    this.selectedDailyReportItem = this.dailyReportData[
      this.selectedCategory
    ].items.find((item) => item.Id === itemId);

    // console.log("SELECTED DAILY REPORT ITEM :::", JSON.parse(JSON.stringify(this.selectedDailyReportItem)));
  }

  // * HANDLES WHEN A PHOTO IS CLICKED
  handleClickPhoto(event) {
    let photoId = event.currentTarget.dataset.photoId;

    let photoDiv = this.template.querySelector(
      '[data-photo-id="' + photoId + '"]'
    );

    if (photoDiv.classList.value.includes("photo-selected")) {
      let photoIndex =
        this.selectedDailyReportItem.ozbee__Daily_Report_Photos__r.findIndex(
          (p) => p.Company_Cam_Photo_Id__c === photoId
        );

      this.selectedDailyReportItem.ozbee__Daily_Report_Photos__r.splice(
        photoIndex,
        1
      );
    } else {
      let selectedPhoto = this.projectPhotos.find(
        (photo) => photo.id === photoId
      );

      // console.log("SELECTED PHOTO :::", JSON.parse(JSON.stringify(selectedPhoto)));

      if (!this.selectedDailyReportItem.ozbee__Daily_Report_Photos__r) {
        this.selectedDailyReportItem.ozbee__Daily_Report_Photos__r = [];
      }

      this.selectedDailyReportItem.ozbee__Daily_Report_Photos__r.push({
        Company_Cam_Photo_Id__c: photoId,
        ozbee__URL__c: selectedPhoto.annotatedURI,
        ozbee__Production_Job_Report__c: this.recordId,
        ozbee__Daily_Report_Item__c: this.selectedDailyReportItem.Id
      });
    }

    photoDiv.classList.toggle("photo-selected");

    // console.log("SELECTED ITEM PHOTOS :::", JSON.parse(JSON.stringify(this.selectedDailyReportItem.ozbee__Daily_Report_Photos__r)));
  }

  // * HANDLES WHEN THE BACK BUTTON IS CLICKED
  handleClickBack() {
    if (this.showPhotoSelectorPage) {
      this.selectedDailyReportItem = null;
    } else {
      for (const category of Object.values(this.dailyReportData)) {
        category.showTitle = true;
        category.showItems = false;
      }

      if (this.selectedCategory === "Expected Production") {
        console.log(
          JSON.parse(
            JSON.stringify(this.dailyReportData[this.selectedCategory].items)
          )
        );
        this.updateDailyExpectedProductions(
          this.dailyReportData[this.selectedCategory].items
        );
      } else {
        this.updateDailyReportItems(
          this.dailyReportData[this.selectedCategory].items
        );
      }

      this.selectedCategory = null;
    }
  }

  // * HANDLES WHEN THE CLOSE BUTTON IS CLICKED
  handleClickClose() {
    this.closeModal();
  }

  // # PRIVATE METHODS

  // * CLOSES MODAL
  closeModal() {
    const closeQA = new CustomEvent("close");
    this.dispatchEvent(closeQA);
  }

  // * DISPLAY SUCCESS TOAST NOTIFICATION
  showSuccess(message) {
    this.showNotification("Success", message, "success");
  }

  // * DISPLAY ERROR TOAST NOTIFICATION
  showError(message) {
    this.showNotification("Error", message, "success");
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

  // * DETERMINES IF DAILY REPORT DATA EXISTS
  get hasDailyReportData() {
    if (Object.keys(this.dailyReportData).length > 0) {
      return true;
    }
    return false;
  }

  // * RETURNS DAILY REPORT CATEGORIES
  get categories() {
    return Object.values(this.dailyReportData);
  }

  // * AVAILABLE OPTIONS FOR THE REPORT ITEM QUESTION
  get itemStatusOptions() {
    return [
      { label: "Yes", value: "YES" },
      { label: "No", value: "NO" },
      { label: "N/A", value: "N/A" }
    ];
  }

  // * DETERMINES IF PROJECT HAS ANY PHOTOS
  get hasProjectPhotos() {
    if (this.projectPhotos.length > 0) {
      return true;
    }
    return false;
  }

  // * DISPLAYS NUMBER OF SELECTED PHOTOS FOR THE CURRENT ITEM
  get numberOfSelectedPhotos() {
    return this.selectedDailyReportItem?.ozbee__Daily_Report_Photos__r?.length;
  }

  // * DISPLAYS PHOTO SELECTOR PAGE
  get showPhotoSelectorPage() {
    if (this.selectedDailyReportItem) {
      return true;
    }
    return false;
  }

  // * DETERMINES IF THE BACK BUTTON IS DISPLAYED
  get showBackButton() {
    if (this.selectedCategory) {
      return true;
    }
    return false;
  }

  // * DETERMINES IF THE CLOSE BUTTON IS DISPLAYED
  get showCloseButton() {
    if (!this.selectedCategory) {
      return true;
    }
    return false;
  }

  // * DETERMINES IF THE LOADING SPINNER IS DISPLAYED
  get isLoading() {
    if (this.loadingData || this.savingData) {
      return true;
    }
    return false;
  }
}
