class DownloadNotifier < ActionMailer::Base
  helper :UserGeoEdits

  default from: "no-reply@unep-wcmc.org"

  def download_email(download)
    @user = download.user
    @download = download
    attachments['WCMC-031-GID2-2013.pdf'] = File.read("#{Rails.root}/public/exports/WCMC-031-GID2-2013.pdf")

    mail(:to => @user.email,
         :subject => "Your Global Islands Database download is complete!",
         :template_path => "download_notifier",
         :template_name => "download_notifier")
  end
end
