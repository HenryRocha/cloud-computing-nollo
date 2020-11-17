# Create a SSH key pair, used to access the public facing instances.
resource "aws_key_pair" "henryrocha_legionY740_manjaro_kp_region_01" {
  provider   = aws.region_01
  key_name   = "henryrocha-legionY740-manjaro-kp-region-01"
  public_key = file("./aws_tf.pub")
}

resource "aws_key_pair" "henryrocha_legionY740_manjaro_kp_region_02" {
  provider   = aws.region_02
  key_name   = "henryrocha-legionY740-manjaro-kp-region-02"
  public_key = file("./aws_tf.pub")
}
