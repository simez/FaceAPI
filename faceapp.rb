# faceapp.rb
require 'rubygems'
require 'bundler'
Bundler.require
require 'sinatra'

# Load up all our secrets
Dotenv.load

# Set up our AWS authentication for all calls in this app
credentials = Aws::Credentials.new(ENV['AWS_KEY'], ENV['AWS_SECRET'])
Aws.config.update(region: 'us-east-1', credentials: credentials)

FACE_COLLECTION = 'TeremFaces'.freeze

post '/' do
  content_type :json
  client = Aws::Rekognition::Client.new
  response = client.search_faces_by_image(collection_id: FACE_COLLECTION,
                                          max_faces: 1,
                                          face_match_threshold: 80,
                                          image: {
                                            bytes: request.body.read.to_s
                                          })
  if response.face_matches.count > 1
    face = response.face_matches[0].face
    {
      id: face.external_image_id,
      confidence: face.confidence,
      message: 'Face found!'
    }.to_json
  elsif response.face_matches.count.zero?
    { message: 'No face detected!' }.to_json
  else
    {
      id: response.face_matches[0].face.external_image_id,
      confidence: response.face_matches[0].face.confidence,
      message: 'Face found!'
    }.to_json
  end
end
