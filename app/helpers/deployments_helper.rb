module DeploymentsHelper
  def deployment_title(deployment)
    I18n.t("deployment.revision_and_time", :revision => deployment.revision, :time => time_ago_in_words(deployment.created_at))
  end
end
