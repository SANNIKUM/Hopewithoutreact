class WebApi::DownloadsController < ApplicationController

  def getSurveySubmittedList
    asg_names = params[:assignment_names]
    page_number = params[:page_number]
    page_size = params[:page_size]

    asg_names = (asg_names.class.name == "Array" ? asg_names : [asg_names])
    sf_ids1 = FilteredSubmittedFormIds.run(asg_names)
    sfs = SubmittedForm.where(id: sf_ids1).paginate(:page => page_number,:per_page => page_size)#.to_a.uniq{|sf| sf.request_id}


    sfs_unique = sfs.to_a.uniq{|sf| sf.request_id}
    fvs = FormValue.where(submitted_form_id: sfs_unique.map(&:id))
    ffs = FormField.where(id: fvs.map(&:form_field_id)).order(:name)
    arr = DataForCsv::Pagination.run(ffs, sfs_unique)
    render :json => {
    :current_page => sfs.current_page,
    :per_page => sfs.per_page,
    :total_entries => sfs.total_entries,
    :total_pages => sfs.total_pages,
    :data => sfs,
    :arr => arr
  }

    # render json: arr
  end

  def download
    asg_name = params[:assignment_name]
    file_name = params[:file_name]
    
    asg_name = asg_name.gsub("[", '').gsub(']', '').split(',')
    csv_file = CSV.generate({}) do |csv|
      arr = DataForCsv::Main.run(asg_name)
      arr.each do |row|
        csv << row
      end
    end
    send_data csv_file, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{file_name}.csv"
  end
end
