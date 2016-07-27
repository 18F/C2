@setupC2TestParams = ->
  {
    editMode: getEditModeContent(),
    updateView: getUpdateViewContent(),
    formState: getRequestDetailsForm(),
    detailsForm: getRequestDetailsForm(),
    detailsSave: getRequestDetailsForm(),
    attachmentCard: getAttachmentContent(),
    observerCard: getObserverContent(),
    actionBar: getActionBarContent(),
    undoCheck: getRequestDetailsForm(),
    activityCard: getActivityContent(),
    modalCard: getModalCardContent()
  }

@getUpdateViewContent = ->
  $('
    <div id="mode-parent"></div>
  ')

@getEditModeContent = ->
  $('
    <div class="view-mode" id="mode-parent"></div>
  ')

@getNotificationContent = ->
  $('
    <div class="action-bar-template" id="action-bar-status">
      <ul>
        <div></div>
      </ul>
    </div>
  ')

@getAttachmentContent = ->
  $('
    <div id="card-for-attachments"></div>
  ')
  .html('
    <label for="attachment_file" class="attachment-label">file label</label>
      <form id="new_attachment">
        <input id="attachment_file" type="file">
        <button type="submit">
      </form>
      <ul class="attachment-list"></ul>
  ')

@getActionBarContent = ->
  $(
    '<div class="action-bar-template" id="action-bar-wrapper">
      <ul id="request-actions">
        <li class="cancel-button">
          <button value="Cancel">
            <span>Cancel</span>
          </button>
        </li>
        <li class="save-button">
          <button value="Save">
            <span>Save</span>
          </button>
        </li>
      </ul>
    </div>'
  )

@getRequestDetailsForm = ->
  $('
    <div id="request-details-card">
      <form action="url">
        <label>
          <input id="field_1" name="field_1" value="10">
        </label>
        <label>
          <input id="field_2" name="field_2" value="ten">
        </label>
        <input id="submit" type="Submit">
      </form>
    </div>
  ')

@getObserverContent = ->
  $('
    <div id="card-for-observers">
      <ul class="observer-list"></ul>
      <form class="new_observation" id="new_observation">
      <select id="observation_user_id" class="js-selectize">
        <option value="user1@test.com">user1@test.com</option>
      </select>
      <input class="form-field no-animation" style="display: inline;" data-hide-until-select="observation_user_id" type="text" name="observation[reason]" id="observation_reason">
    </div>
    ')

@getActivityContent = ->
  $('
    <div id="card-for-activity">
      <form class="new_comment" id="new_comment">
        <textarea rows="5" name="comment[comment_text]" id="comment_comment_text" placeholder="Your comment will be sent to all observers associated with this request."></textarea>
        <input type="submit" name="commit" value="Send" id="add_a_comment">
      </form>
    </div>
    ')

@getModalCardContent = ->
  $('
      <div class="popup-modal">
        <div class="popup-content">
          <form>
            <textarea />
            <input type="submit"></input>
            <a class="cancel-cancel-link">Cancel</a>
          </form>
        </div>
      </div>
    ')
