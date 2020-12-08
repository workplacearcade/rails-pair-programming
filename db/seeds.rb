# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

def create_idempotent(klass, attrs, match_attrs = nil)
  match_attrs ||= {name: attrs[:name]}
  item = klass.where(match_attrs).first_or_initialize
  item.update!(attrs)
  puts "#{klass}: #{match_attrs}"
  item
end

def create_idempotent_list(klass, attr_list)
  attr_list.map do |attrs|
    create_idempotent(klass, attrs)
  end
end

#Creating Levels
for x in 1..100 do
  title = "Level #{x}"
  if x == 1
    level_start = 0
  else
    level_start = Level.find_by(level_number: x - 1).level_end
  end

  level_number = x
  level_end = level_start + level_number * 75

  attrs = {
    title: title,
    level_start: level_start,
    level_end: level_end,
    level_number: level_number
  }
  create_idempotent(Level, attrs, {level_number: level_number})
end

# Creating our test company and a team
entity = Entity.create(name: "My Test Company")
team = Team.create(name: "My Cool Team", entity: entity)

# Create four users. Then assign them to a team and give them integration identifiers
user_one = User.create(firstname: "James", lastname: "McLaren", entity: entity)
TeamAssignment.create(user: user_one, team: team, assignment_type: :primary)
IntegrationIdentifier.create(user: user_one, source: :iqmetrix, identifier: '1')
IntegrationIdentifier.create(user: user_one, source: :iqmetrix, identifier: 'james.mclaren')

user_two = User.create(firstname: "David", lastname: "Parry", entity: entity)
TeamAssignment.create(user: user_two, team: team, assignment_type: :primary)
IntegrationIdentifier.create(user: user_two, source: :integration, identifier: '2')
IntegrationIdentifier.create(user: user_two, source: :integration, identifier: 'david.parry')

user_three = User.create(firstname: "Odisha", lastname: "Odicho", entity: entity)
TeamAssignment.create(user: user_three, team: team, assignment_type: :primary)
IntegrationIdentifier.create(user: user_three, source: :iqmetrix, identifier: '3')
IntegrationIdentifier.create(user: user_three, source: :iqmetrix, identifier: 'odisha.odicho')

user_four = User.create(firstname: "Sharon", lastname: "Chen", entity: entity)
TeamAssignment.create(user: user_four, team: team, assignment_type: :primary)
IntegrationIdentifier.create(user: user_four, source: :iqmetrix, identifier: 'sharon.chen')

# Now we create a KPI Group and assign it to all four users
kpi_group = KpiGroup.create(title: 'Phones', verb: 'Sold', entity: entity, source: :integration)
kpi = Kpi.create(title: kpi_group.title, kpi_group: kpi_group)
UserTarget.create(kpi: kpi, user: user_one)
UserTarget.create(kpi: kpi, user: user_three)
UserTarget.create(kpi: kpi, user: user_four)

# Finally we create the required IQMetrix logic
partner = IQMetrix::Partner.create(name: "My Awesome Company", entity: entity)
IQMetrix::PerformanceGroup.create(name: kpi_group.name, kpi_group: kpi_group, quantity_attribute: 'quantity', iq_metrix_partner: partner)