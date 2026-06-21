// jest.mocks.js
module.exports = {
  'lightning/navigation': {
    NavigationMixin: () => {}
  },
  'lightning/platformShowToastEvent': {
    ShowToastEvent: class {}
  },
  'lightning/uiRecordApi': {
    getRecord: jest.fn(),
    updateRecord: jest.fn()
  }
};
