class Officer::AssignmentsController < Officer::BaseController
  before_action :set_issue

  # Atomic claim: only succeeds if the issue is unassigned and unresolved.
  # Prevents two officers from simultaneously "taking on" the same issue.
  def create
    if @issue.resolved?
      redirect_to officer_issue_path(@issue), alert: "This issue is already resolved." and return
    end

    updated = Issue.where(id: @issue.id, assigned_to_id: nil)
                   .update_all(assigned_to_id: Current.user.id, assigned_at: Time.current)

    if updated == 1
      redirect_to officer_issue_path(@issue), notice: "You've taken this issue."
    else
      @issue.reload
      other = @issue.assigned_to&.display_name || "another officer"
      redirect_to officer_issue_path(@issue), alert: "Already assigned to #{other}."
    end
  end

  # Release — only the assigned officer can give the issue back.
  def destroy
    if @issue.assigned_to_id != Current.user.id
      redirect_to officer_issue_path(@issue), alert: "You can only release issues assigned to you." and return
    end
    @issue.update!(assigned_to_id: nil, assigned_at: nil)
    redirect_to officer_issue_path(@issue), notice: "Issue released."
  end

  private

  def set_issue
    @issue = Issue.find(params[:issue_id])
  end
end
