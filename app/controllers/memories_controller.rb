class MemoriesController < ApplicationController
 layout "board", only: :index 



  def index
    @memories = Memory.order( "created_at DESC" ).page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @memories }
    end
  end



  def show
    @memory = Memory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @memory }
    end
  end



  def new
    @memory = Memory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @memory }
    end
  end


  def edit
    @memory = Memory.find(params[:id])
  end



  def create
    @memory = Memory.new(params[:memory])

    respond_to do |format|
      if @memory.save
        format.html { redirect_to @memory, notice: 'Memory was successfully created.' }
        format.json { render json: @memory, status: :created, location: @memory }
      else
        format.html { render action: "new" }
        format.json { render json: @memory.errors, status: :unprocessable_entity }
      end
    end
  end



  def update
    @memory = Memory.find(params[:id])

    respond_to do |format|
      if @memory.update_attributes(params[:memory])
        format.html { redirect_to memories_path, notice: 'Memory was successfully updated.' }
        format.json { render json: @memory }
      else
        format.html { render action: "edit" }
        format.json { render json: @memory.errors, status: :unprocessable_entity }
      end
    end
  end



  def destroy
    @memory = Memory.find(params[:id])
    @memory.destroy

    respond_to do |format|
      format.html { redirect_to memories_url }
      format.json { head :no_content }
    end
  end
end
