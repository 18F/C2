#= require jquery
#= require ladda/spin.min
#= require ladda/ladda.min
#= require ladda/ladda.jquery.min
#= require jquery.dirrty
#= require moment
#= require required_for_submit
#= require details/state/edit_mode
#= require details/state/form_change_state
#= require details/views/view_helper
#= require details/views/approvals_card
#= require details/views/action_bar
#= require details/views/attachment_card
#= require details/views/details_request_card
#= require details/views/activity_card
#= require details/views/observer_card
#= require details/views/summary_bar
#= require details/views/modal_card
#= require details/views/notifications
#= require details/views/view_helper
#= require details/views/approvals_card
#= require details/data/update_view
#= require details/data/details_save
#= require details/shell/c2
#= require details/shell/action_bar_bridge
#= require details/details_helper
#= require spec_helper

describe 'C2', ->

  describe '#setup', ->
    it "checks for c2", ->
      c2 = new C2()
      expect(c2 instanceof C2).to.eql(true)

    it "checks for each constructor", ->
      c2 = new C2()
      expect(c2.attachmentCardController instanceof AttachmentCardController).to.eql(true)
      expect(c2.activityCardController instanceof ActivityCardController).to.eql(true)
      expect(c2.editMode instanceof EditStateController).to.eql(true)
      expect(c2.detailsRequestCard instanceof DetailsRequestCard).to.eql(true)
      expect(c2.formState instanceof FormChangeState).to.eql(true)
      expect(c2.actionBar instanceof ActionBar).to.eql(true)
      expect(c2.detailsSave instanceof DetailsSave).to.eql(true)
      expect(c2.summaryBar instanceof SummaryBar).to.eql(true)
      expect(c2.modals instanceof ModalController).to.eql(true)

    it "check config passing test param actionBar", ->
      test = "action-bar-test"
      testParam = {
        actionBar: test
      }
      c2 = new C2(testParam)
      expect(c2.config.actionBar).to.eql(test)

    it "check config passing test param editMode", ->
      test = "edit-mode-test"
      testParam = {
        editMode: test
      }
      c2 = new C2(testParam)
      expect(c2.config.editMode).to.eql(test)

    it "check config passing test param attachmentCard", ->
      test = "attachment-card-test"
      testParam = {
        attachmentCard: test
      }
      c2 = new C2(testParam)
      expect(c2.config.attachmentCard).to.eql(test)

    it "check config passing test param activityCard", ->
      test = "activity-card-test"
      testParam = {
        activityCard: test
      }
      c2 = new C2(testParam)
      expect(c2.config.activityCard).to.eql(test)

    it "check config passing test param summaryBar", ->
      test = "summary-bar"
      testParam = {
        summaryBar: test
      }
      c2 = new C2(testParam)
      expect(c2.config.summaryBar).to.eql(test)

    it "check config passing test param modalCard", ->
      test = "cancel-card-test"
      testParam = {
        modalCard: test
      }
      c2 = new C2(testParam)
      expect(c2.config.modalCard).to.eql(test)

    it "check config passing test param formState", ->
      test = "form-state-test"
      testParam = {
        formState: test
      }
      c2 = new C2(testParam)
      expect(c2.config.formState).to.eql(test)

    it "check config passing test param detailsSave", ->
      test = "details-save-test"
      testParam = {
        detailsSave: test
      }
      c2 = new C2(testParam)
      expect(c2.config.detailsSave).to.eql(test)

    it "check config passing test param updateView", ->
      test = "update-view"
      testParam = {
        updateView: test
      }
      c2 = new C2(testParam)
      expect(c2.config.updateView).to.eql(test)

  describe '#events _actionBarState', ->
    it "editMode is on when state when edit-mode:on", ->

  describe '#events _actionBarSave', ->
    it "action-bar-clicked:save is fired through details-form:save", ->
      flag = false
      testParams = setupC2TestParams()
      c2 = new C2(testParams)
      c2.detailsSave.el.on 'details-form:save', ->
        flag = true
      c2.detailsSave.el.trigger('details-form:save')
      expect(flag).to.eql(true)

  describe '#events _setupNotifications', ->
    it "create the event hook that notification triggers", ->

  describe '#handleSaveError', ->
    it "checks for one errors", ->
    it "checks for multiple errors", ->

  describe '#events notification', ->
    it "checks for one success response", ->

  describe 'trigger events on dirrty', ->
    it "make sure dirrty is triggered on form", ->
    it "make sure dirrty is reinit on save", ->

  describe 'when request detail is interacted', ->
    it "clicking modify will load the view in edit mode", ->
    it "clicking modify should not load any notifications", ->
    it "clicking cancel button from modify will revert to view mode", ->
    it "clicking cancel in action bar will revert to view mode", ->
    it "clicking save in action bar will load modal for save confirm", ->
    it "clicking cancel button in save confirm will close modal", ->
    it "clicking -x- button in save confirm will close modal", ->
    it "make sure dirrty is reinit on save", ->
