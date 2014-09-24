# == Schema Information
#
# Table name: tag_namespaces
#
#  id              :integer          not null, primary key
#  organization_id :integer
#  namespace       :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class TagNamespace < ActiveRecord::Base
  validates :namespace, presence: true, uniqueness: {scope: 'organization_id' }
  validates :organization, presence: true

  has_many :tags, foreign_key: 'namespace_id'
  belongs_to :organization
  has_many :charges, through: :tags

  def self.find_or_create!(organization, name)
    namespace = where(namespace: name, organization: organization).first
    if namespace.nil?
      namespace = TagNamespace.create!(namespace: name, organization: organization)
    end
    namespace
  end

  def incrby(amount, name, status='live')
    redis.zincrby(self.most_raised_key(status), amount, name)
    redis.incrby(self.total_raised_amount_key, amount)
    redis.incr(self.total_charges_count_key)
  end

  def total_raised
    redis.get(total_raised_amount_key).to_i
  end

  def raised_for_tag(name, status='live')
    redis.zscore(most_raised_key(status), name).to_i
  end

  def total_charges_count
    redis.get(total_charges_count_key).to_i
  end

  def total_charges_count_key
    "#{organization.to_param}/namespaces/#{namespace}/total_charges_key"
  end

  def total_raised_amount_key
    "#{organization.to_param}/namespaces/#{namespace}/total_raised_key"
  end

  def most_raised_key(status='live')
    "#{organization.to_param}/namespaces/#{namespace}/most_raised_tags/#{status}"
  end

  def to_param
    namespace
  end

  private

  def redis
    PragueServer::Application.redis
  end
end
