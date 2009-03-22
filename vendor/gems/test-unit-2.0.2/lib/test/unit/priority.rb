require "fileutils"
require "tmpdir"

module Test
  module Unit
    module Priority
      class << self
        def included(base)
          base.extend(ClassMethods)

          base.class_eval do
            setup :priority_setup, :before => :prepend
            teardown :priority_teardown, :after => :append
          end
        end

        @@enabled = false
        def enabled?
          @@enabled
        end

        def enable
          @@enabled = true
        end

        def disable
          @@enabled = false
        end
      end

      class Checker
        class << self
          def have_priority?(name)
            singleton_class = (class << self; self; end)
            singleton_class.method_defined?(priority_check_method_name(name))
          end

          def need_to_run?(test)
            priority = test[:priority] || :normal
            if have_priority?(priority)
              send(priority_check_method_name(priority), test)
            else
              true
            end
          end

          def run_priority_must?(test)
            true
          end

          def run_priority_important?(test)
            rand > 0.1
          end

          def run_priority_high?(test)
            rand > 0.3
          end

          def run_priority_normal?(test)
            rand > 0.5
          end

          def run_priority_low?(test)
            rand > 0.75
          end

          def run_priority_never?(test)
            false
          end

          private
          def priority_check_method_name(priority_name)
            "run_priority_#{priority_name}?"
          end
        end

        attr_reader :test
        def initialize(test)
          @test = test
        end

        def setup
          FileUtils.rm_f(passed_file)
        end

        def teardown
          if @test.send(:passed?)
            FileUtils.touch(passed_file)
          else
            FileUtils.rm_f(passed_file)
          end
        end

        def need_to_run?
          !previous_test_success? or self.class.need_to_run?(@test)
        end

        private
        def previous_test_success?
          File.exist?(passed_file)
        end

        def result_dir
          components = [".test-result",
                        @test.class.name || "AnonymousTestCase",
                        escaped_method_name]
          parent_directories = [File.dirname($0), Dir.pwd]
          if Process.respond_to?(:uid)
            parent_directories << File.join(Dir.tmpdir, Process.uid.to_s)
          end
          parent_directories.each do |parent_directory|
            dir = File.expand_path(File.join(parent_directory, *components))
            begin
              FileUtils.mkdir_p(dir)
              return dir
            rescue Errno::EACCES
            end
          end

          raise Errno::EACCES, parent_directories.join(", ")
        end

        def passed_file
          File.join(result_dir, "passed")
        end

        def escaped_method_name
          @test.method_name.to_s.gsub(/[!?=]$/) do |matched|
            case matched
            when "!"
              ".destructive"
            when "?"
              ".predicate"
            when "="
              ".equal"
            end
          end
        end
      end

      module ClassMethods
        def priority(name, *tests)
          unless Checker.have_priority?(name)
            raise ArgumentError, "unknown priority: #{name}"
          end
          attribute(:priority, name, {:keep => true}, *tests)
        end
      end

      def priority_setup
        return unless Priority.enabled?
        Checker.new(self).setup
      end

      def priority_teardown
        return unless Priority.enabled?
        Checker.new(self).teardown
      end
    end
  end
end