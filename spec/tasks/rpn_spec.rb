# frozen_string_literal: true

RSpec.describe "rpn rake tasks" do
  let(:overrides_path) do
    Rails.root.join("plugins/discourse-modifications/config/site_setting_overrides.yml").to_s
  end

  before { enable_current_plugin }

  describe "rpn:apply_settings" do
    def run_task
      capture_stdout { invoke_rake_task("rpn:apply_settings") }
    end

    it "persists each setting and creates an audit log entry per change" do
      allow(YAML).to receive(:safe_load_file).and_return(
        "max_post_length" => 1000,
        "login_required" => true,
      )

      expect { run_task }.to change { UserHistory.count }.by(2)
      expect(SiteSetting.max_post_length).to eq(1000)
      expect(SiteSetting.login_required).to eq(true)
    end

    it "skips settings already at the target value without creating an audit log entry" do
      SiteSetting.max_post_length = 1000
      allow(YAML).to receive(:safe_load_file).and_return("max_post_length" => 1000)

      expect { run_task }.not_to change { UserHistory.count }
    end

    it "prints a warning and does not raise when the overrides file is missing" do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(overrides_path).and_return(false)

      expect { run_task }.not_to raise_error
      expect(run_task).to include("No overrides file found")
    end

    it "prints a message and does not raise when the overrides file is empty" do
      allow(YAML).to receive(:safe_load_file).and_return(nil)

      expect { run_task }.not_to raise_error
      expect(run_task).to include("No settings defined")
    end

    it "prints an error and exits with failure when a setting name is unknown" do
      allow(YAML).to receive(:safe_load_file).and_return("nonexistent_setting_xyz" => "value")

      expect { run_task }.to raise_error(SystemExit) do |error|
        expect(error.status).to eq(1)
      end
    end
  end
end
