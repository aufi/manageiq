require "spec_helper"
include UiConstants

describe MiqPolicyController do
  context "::MiqActions" do
    context "#action_edit" do
      before :each do
        @action = FactoryGirl.create(:miq_action, :name => "Test_Action")
        controller.instance_variable_set(:@sb, {})
        controller.stub(:replace_right_cell)
        controller.stub(:action_build_cat_tree)
        controller.stub(:get_node_info)
        controller.stub(:action_get_info)
      end

      it "first time in" do
        controller.action_edit
        expect(controller.send(:flash_errors?)).not_to be_true
      end

      it "Test reset button" do
        controller.instance_variable_set(:@_params, :id => @action.id, :button => "reset")
        controller.action_edit
        expect(assigns(:flash_array).first[:message]).to include("reset")
        expect(controller.send(:flash_errors?)).not_to be_true
      end

      it "Test cancel button" do
        controller.instance_variable_set(:@sb, {:trees => {:action_tree => {:active_node => "a-#{@action.id}"}}, :active_tree => :action_tree})
        controller.instance_variable_set(:@_params, :id => @action.id, :button => "cancel")
        controller.action_edit
        expect(assigns(:flash_array).first[:message]).to include("cancelled")
        expect(controller.send(:flash_errors?)).not_to be_true
      end

      it "Test saving an action without selecting a Tag" do
        controller.instance_variable_set(:@_params, :id => @action.id)
        controller.action_edit
        expect(controller.send(:flash_errors?)).not_to be_true
        edit = controller.instance_variable_get(:@edit)
        edit[:new][:action_type] = "tag"
        session[:edit] = assigns(:edit)
        controller.instance_variable_set(:@_params, :id => @action.id, :button => "save")
        controller.should_receive(:render)
        controller.action_edit
        expect(assigns(:flash_array).first[:message]).to include("At least one Tag")
        expect(assigns(:flash_array).first[:message]).not_to include("saved")
        expect(controller.send(:flash_errors?)).to be_true
      end

      it "Test saving an action after selecting a Tag" do
        controller.instance_variable_set(:@_params, :id => @action.id)
        controller.action_edit
        expect(controller.send(:flash_errors?)).not_to be_true
        edit = controller.instance_variable_get(:@edit)
        edit[:new][:action_type] = "tag"
        edit[:new][:options] = {}
        edit[:new][:options][:tags] = "Some Tag"
        session[:edit] = assigns(:edit)
        controller.instance_variable_set(:@_params, :id => @action.id, :button => "save")
        controller.action_edit
        expect(assigns(:flash_array).first[:message]).not_to include("At least one Tag")
        expect(assigns(:flash_array).first[:message]).to include("saved")
        expect(controller.send(:flash_errors?)).not_to be_true
      end
    end
  end
end
