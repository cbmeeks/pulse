(load "spinoffs/wav2pwm.lisp")

(defun make-wav (name file bass)
  (format nil
    (+ "mplayer -vo null -vc null -ao pcm:fast:file=obj/~A.wav ~A~%"
       "sox obj/~A.wav obj/~A_filtered.wav bass ~A lowpass 2000 compand 0.3,1 6:-70,-60,-20 -5 -90 0.2 gain 4~%")
          name file name name bass))

(defun make-conversion (name tv)
  (format nil
    "sox obj/~A_filtered.wav -c 1 -b 16 -r ~A obj/~A_downsampled_~A.wav~%"
    name (pwm-pulse-rate tv) name (downcase (symbol-name tv))))

(print-pwm-info)
(put-file "obj/_make.sh"
  (+ (make-wav "ohne_dich" "spinoffs/ohne_dich.mp3" -56)
     (make-conversion "ohne_dich" :pal)
     (make-conversion "ohne_dich" :ntsc)
     (make-wav "mario" "spinoffs/mario.flv" -56)
     (make-conversion "mario" :pal)
     (make-conversion "mario" :ntsc)))

(quit)
