class MenuGroupsController < ApplicationController
  before_action :set_menu_group, only: [:show, :edit, :update, :destroy]

  # GET /menu_groups
  # GET /menu_groups.json
  def index
    @menu_groups = MenuGroup.all
  end

  # GET /menu_groups/1
  # GET /menu_groups/1.json
  def show
  end

  # GET /menu_groups/new
  def new
    @menu_group = MenuGroup.new
  end

  # GET /menu_groups/1/edit
  def edit
  end

  # POST /menu_groups
  # POST /menu_groups.json
  def create
    @menu_group = MenuGroup.new(menu_group_params)

    respond_to do |format|
      if @menu_group.save
        format.html { redirect_to @menu_group, notice: 'Menu group was successfully created.' }
        format.json { render :show, status: :created, location: @menu_group }
      else
        format.html { render :new }
        format.json { render json: @menu_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /menu_groups/1
  # PATCH/PUT /menu_groups/1.json
  def update
    respond_to do |format|
      if @menu_group.update(menu_group_params)
        format.html { redirect_to @menu_group, notice: 'Menu group was successfully updated.' }
        format.json { render :show, status: :ok, location: @menu_group }
      else
        format.html { render :edit }
        format.json { render json: @menu_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /menu_groups/1
  # DELETE /menu_groups/1.json
  def destroy
    @menu_group.destroy
    respond_to do |format|
      format.html { redirect_to menu_groups_url, notice: 'Menu group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_menu_group
      @menu_group = MenuGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def menu_group_params
      params.require(:menu_group).permit(:name, :description, :user_id)
    end
end
