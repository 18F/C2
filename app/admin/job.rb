# based on https://gist.github.com/webmat/1887148
ActiveAdmin.register DelayedJob, as: 'Job' do
  actions :index, :show, :edit, :update, :destroy

  index do
    column :id
    column :queue
    column :priority
    column :attempts
    column :failed_at
    column :run_at
    column :created_at
    column :locked_by
    column :locked_at
    actions
  end

  form do |f|
    f.inputs "Scheduling" do
      f.input :priority
      f.input :queue
      f.input :run_at
    end

    f.inputs "Details" do
      f.input :id, input_html:          {disabled: true}
      f.input :created_at, input_html:  {disabled: true}
      f.input :updated_at, input_html:  {disabled: true}
      f.input :handler, input_html:     {disabled: true}
    end

    f.inputs "Diagnostics" do
      f.input :attempts,    input_html: {disabled: true}
      f.input :failed_at,   input_html: {disabled: true}
      f.input :last_error,  input_html: {disabled: true}
      f.input :locked_at,   input_html: {disabled: true}
      f.input :locked_by,   input_html: {disabled: true}
    end
    f.buttons
  end

  action_item :only => [:edit] do
    link_to 'Delete Job', admin_job_path(resource),
            'data-method' => :delete, 'data-confirm' => 'Are you sure?'
  end

  action_item :only => [:show, :edit] do
    link_to 'Schedule now', run_now_admin_job_path(resource), 'data-method' => :post,
      :title => 'Cause a job scheduled in the future to run now.'
  end

  action_item :only => [:show, :edit] do
    link_to 'Reset Job', reset_admin_job_path(resource), 'data-method' => :post,
      :title => 'Resets the state caused by errors. Lets a worker give it another go ASAP.'
  end

  member_action :run_now, :method => :post do
    resource.update_attributes run_at: Time.now
    redirect_to action: :index
  end

  member_action :reset, :method => :post do
    resource.update_attributes locked_at: nil, locked_by: nil, attempts: 0, last_error: nil
    resource.update_attribute :attempts, 0
    redirect_to action: :index
  end

end
