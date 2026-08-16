# Lets `app/components/ui/**` resolve to the `UI::` namespace instead of `Ui::`.
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "UI"
  inflect.acronym "SEO"
end
