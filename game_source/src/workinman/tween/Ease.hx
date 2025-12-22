package workinman.tween;

class Ease {

	/**********************************************************
	@description
	**********************************************************/
	// TODO FOR MAPPING
	// static private function _tweenEaseBoth( pStartVal:Float, pDiff:Float, pEl:Float,  pDur:Float ) : Float
	// {
	// 	return _easeInOutQuad( pEl, pStartVal, pDiff, pDur);
	// }

	/**
	* Generates linear tween with constant velocity and no acceleration.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function linear(t:Float, b:Float, c:Float, d:Float):Float {
		return c*t/d+b;
	}

	/**
	* Generates quadratic, or "normal" easing in tween where equation for motion is based on a squared variable.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inQuad(t:Float, b:Float, c:Float, d:Float):Float {
		return c*(t /= d)*t+b;
	}

	/**
	* Generates quadratic, or "normal" easing out tween where equation for motion is based on a squared variable.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outQuad(t:Float, b:Float, c:Float, d:Float):Float {
		return -c*(t /= d)*(t-2)+b;
	}

	/**
	* Generates quadratic, or "normal" easing in-out tween (two half tweens fused together) where equation for motion is based on a squared variable.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inOutQuad(t:Float, b:Float, c:Float, d:Float):Float {
		if ((t /= d/2)<1) {
			return c/2*t*t+b;
		}
		return -c/2*((--t)*(t-2)-1)+b;
	}

	/**
	* Generates exponential (sharp curve) easing in tween where equation for motion is based on the number 2 raised to a multiple of 10.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inExpo(t:Float, b:Float, c:Float, d:Float):Float {
		return (t == 0) ? b : c*Math.pow(2, 10*(t/d-1))+b;
	}

	/**
	* Generates exponential (sharp curve) easing out tween where equation for motion is based on the number 2 raised to a multiple of 10.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outExpo(t:Float, b:Float, c:Float, d:Float):Float {
		return (t == d) ? b+c : c*(-Math.pow(2, -10*t/d)+1)+b;
	}

	/**
	* Generates exponential (sharp curve) easing in-out tween where equation for motion is based on the number 2 raised to a multiple of 10.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inOutExpo(t:Float, b:Float, c:Float, d:Float):Float {
		if (t == 0) {
			return b;
		}
		if (t == d) {
			return b+c;
		}
		if ((t /= d/2)<1) {
			return c/2*Math.pow(2, 10*(t-1))+b;
		}
		return c/2*(-Math.pow(2, -10*--t)+2)+b;
	}

	/**
	* Generates exponential (sharp curve) easing out-in tween where equation for motion is based on the number 2 raised to a multiple of 10.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outInExpo(t:Float, b:Float, c:Float, d:Float):Float {
		if (t == 0) {
			return b;
		}
		if (t == d) {
			return b+c;
		}
		if ((t /= d/2)<1) {
			return c/2*(-Math.pow(2, -10*t)+1)+b;
		}
		return c/2*(Math.pow(2, 10*(t-2))+1)+b;
	}

	/**
	* Generates elastic easing in tween where equation for motion is based on Hooke's Law of <code>F = -kd</code>.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @param a		(optional) amplitude, or magnitude of wave's oscillation
	* @param p		(optional) period
	* @return		position
	*/
	public static function inElastic(t:Float, b:Float, c:Float, d:Float):Float {
		if (t == 0) {
			return b;
		}
		if ((t /= d) == 1) {
			return b+c;
		}
		var p = d*.3;
		var a = c;
		var s = p/4;
		return -(a*Math.pow(2, 10*(t -= 1))*Math.sin((t*d-s)*(2*Math.PI)/p))+b;
	}

	/**
	* Generates elastic easing out tween where equation for motion is based on Hooke's Law of <code>F = -kd</code>.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @param a		(optional) amplitude, or magnitude of wave's oscillation
	* @param p		(optional) period
	* @return		position
	*/
	public static function outElastic( t:Float, b:Float, c:Float, d:Float):Float {
		if (t == 0) {
			return b;
		}
		if ((t /= d) == 1) {
			return b+c;
		}
		var p = d*.3;
		var a = c;
		var s = p/4;
		return (a*Math.pow(2, -10*t)*Math.sin((t*d-s)*(2*Math.PI)/p)+c+b);
	}

	/**
	* Generates elastic easing in-out tween where equation for motion is based on Hooke's Law of <code>F = -kd</code>.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @param a		(optional) amplitude, or magnitude of wave's oscillation
	* @param p		(optional) period
	* @return		position
	*/
	public static function inOutElastic(t:Float, b:Float, c:Float, d:Float):Float {
		if (t == 0) {
			return b;
		}
		if ((t /= d/2) == 2) {
			return b+c;
		}
		var p = d*(.3*1.5);
		var a = c;
		var s = p/4;
		if (t<1) {
			return -.5*(a*Math.pow(2, 10*(t -= 1))*Math.sin((t*d-s)*(2*Math.PI)/p))+b;
		}
		return a*Math.pow(2, -10*(t -= 1))*Math.sin((t*d-s)*(2*Math.PI)/p)*.5+c+b;
	}

	/**
	* Generates elastic easing out-in tween where equation for motion is based on Hooke's Law of <code>F = -kd</code>.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @param a		(optional) amplitude, or magnitude of wave's oscillation
	* @param p		(optional) period
	* @return		position
	*/
	public static function outInElastic(t:Float, b:Float, c:Float, d:Float):Float {
		if (t == 0) {
			return b;
		}
		if ((t /= d/2) == 2) {
			return b+c;
		}
		var p = d*(.3*1.5);
		var a = c;
		var s = p/4;
		if (t<1) {
			return .5*(a*Math.pow(2, -10*t)*Math.sin((t*d-s)*(2*Math.PI)/p))+c/2+b;
		}
		return c/2+.5*(a*Math.pow(2, 10*(t-2))*Math.sin((t*d-s)*(2*Math.PI)/p))+b;
	}

	/**
	* Generates tween where target backtracks slightly, then reverses direction and moves to position.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @param s		(optional) controls amount of overshoot, with higher value yielding greater overshoot.
	* @return		position
	*/
	public static function inBack(t:Float, b:Float, c:Float, d:Float):Float {
		var s = 1.70158;
		return c*(t /= d)*t*((s+1)*t-s)+b;
	}

	/**
	* Generates tween where target moves and overshoots final position, then reverse direction to reach final position.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @param s		(optional) controls amount of overshoot, with higher value yielding greater overshoot.
	* @return		position
	*/
	public static function outBack(t:Float, b:Float, c:Float, d:Float):Float {
		var s = 1.70158;
		return c*((t=t/d-1)*t*((s+1)*t+s)+1)+b;
	}

	/**
	* Generates tween where target backtracks slightly, then reverses direction towards final position, overshoots final position, then ultimately reverses direction to reach final position.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @param s		(optional) controls amount of overshoot, with higher value yielding greater overshoot.
	* @return		position
	*/
	public static function inOutBack(t:Float, b:Float, c:Float, d:Float):Float {
		var s = 1.70158;
		if ((t /= d/2)<1) {
			return c/2*(t*t*(((s *= (1.525))+1)*t-s))+b;
		}
		return c/2*((t -= 2)*t*(((s *= (1.525))+1)*t+s)+2)+b;
	}

	/**
	* Generates tween where target moves towards and overshoots final position, then ultimately reverses direction to reach its beginning position.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @param s		(optional) controls amount of overshoot, with higher value yielding greater overshoot.
	* @return		position
	*/
	public static function outInBack(t:Float, b:Float, c:Float, d:Float):Float {
		var s = 0.0;
		if ((t /= d/2)<1) {
			return c/2*(--t*t*(((s *= (1.525))+1)*t+1.70158)+1)+b;
		}
		return c/2*(--t*t*(((s *= (1.525))+1)*t-1.70158)+1)+b;
	}

	/**
	* Generates easing out tween where target bounces before reaching final position.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outBounce(t:Float, b:Float, c:Float, d:Float):Float {
		if ((t /= d)<(1/2.75)) {
			return c*(7.5625*t*t)+b;
		} else if (t<(2/2.75)) {
			return c*(7.5625*(t -= (1.5/2.75))*t+.75)+b;
		} else if (t<(2.5/2.75)) {
			return c*(7.5625*(t -= (2.25/2.75))*t+.9375)+b;
		} else {
			return c*(7.5625*(t -= (2.625/2.75))*t+.984375)+b;
		}
	}

	/**
	* Generates easing in tween where target bounces upon entering the animation and then accelarates towards its final position.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inBounce(t:Float, b:Float, c:Float, d:Float):Float {
		return c-outBounce(d-t, 0, c, d)+b;
	}

	/**
	* Generates easing in-out tween where target bounces upon entering the animation and then accelarates towards its final position.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inOutBounce(t:Float, b:Float, c:Float, d:Float):Float {
		if (t<d/2) {
			return inBounce(t*2, 0, c, d)*.5+b;
		} else {
			return outBounce(t*2-d, 0, c, d)*.5+c*.5+b;
		}
	}

	/**
	* Generates easing out-in tween where target bounces upon entering the animation and then accelarates towards its final position.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outInBounce(t:Float, b:Float, c:Float, d:Float):Float {
		if (t<d/2) {
			return outBounce(t*2, 0, c, d)*.5+b;
		}
		return inBounce(t*2-d, 0, c, d)*.5+c*.5+b;
	}

	/**
	* Generates cubic easing in tween where equation for motion is based on the power of three and is a bit more curved than a quadratic EASE.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inCubic(t:Float, b:Float, c:Float, d:Float):Float {
		return c*(t /= d)*t*t+b;
	}

	/**
	* Generates cubic easing out tween where equation for motion is based on the power of three and is a bit more curved than a quadratic EASE.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outCubic(t:Float, b:Float, c:Float, d:Float):Float {
		return c*((t=t/d-1)*t*t+1)+b;
	}

	/**
	* Generates cubic easing in-out tween where equation for motion is based on the power of three and is a bit more curved than a quadratic EASE.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inOutCubic(t:Float, b:Float, c:Float, d:Float):Float {
		if ((t /= d/2)<1) {
			return c/2*t*t*t+b;
		}
		return c/2*((t -= 2)*t*t+2)+b;
	}

	/**
	* Generates cubic easing out-in tween where equation for motion is based on the power of three and is a bit more curved than a quadratic EASE.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outInCubic(t:Float, b:Float, c:Float, d:Float):Float {
		t /= d/2;
		return c/2*(--t*t*t+1)+b;
	}

	/**
	* Generates quartic easing in tween where equation for motion is based on the power of four and feels a bit "other-worldly" as the acceleration becomes more exaggerated.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inQuart(t:Float, b:Float, c:Float, d:Float):Float {
		return c*(t /= d)*t*t*t+b;
	}

	/**
	* Generates quartic easing out tween where equation for motion is based on the power of four and feels a bit "other-worldly" as the acceleration becomes more exaggerated.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outQuart(t:Float, b:Float, c:Float, d:Float):Float {
		return -c*((t=t/d-1)*t*t*t-1)+b;
	}

	/**
	* Generates quartic easing in-out tween where equation for motion is based on the power of four and feels a bit "other-worldly" as the acceleration becomes more exaggerated.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inOutQuart(t:Float, b:Float, c:Float, d:Float):Float {
		if ((t /= d/2)<1) {
			return c/2*t*t*t*t+b;
		}
		return -c/2*((t -= 2)*t*t*t-2)+b;
	}

	/**
	* Generates quartic easing out-in tween where equation for motion is based on the power of four and feels a bit "other-worldly" as the acceleration becomes more exaggerated.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outInQuart(t:Float, b:Float, c:Float, d:Float):Float {
		if ((t /= d/2)<1) {
			return -c/2*(--t*t*t*t-1)+b;
		}
		return c/2*(--t*t*t*t+1)+b;
	}

	/**
	* Generates quartic easing in tween where equation for motion is based on the power of five and motion starts slow and becomes quite fast in what appears to be a fairly pronounced curve.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inQuint(t:Float, b:Float, c:Float, d:Float):Float {
		return c*(t /= d)*t*t*t*t+b;
	}

	/**
	* Generates quartic easing out tween where equation for motion is based on the power of five and motion starts slow and becomes quite fast in what appears to be a fairly pronounced curve.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outQuint(t:Float, b:Float, c:Float, d:Float):Float {
		return c*((t=t/d-1)*t*t*t*t+1)+b;
	}

	/**
	* Generates quartic easing in-out tween where equation for motion is based on the power of five and motion starts slow and becomes quite fast in what appears to be a fairly pronounced curve.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inOutQuint(t:Float, b:Float, c:Float, d:Float):Float {
		if ((t /= d/2)<1) {
			return c/2*t*t*t*t*t+b;
		}
		return c/2*((t -= 2)*t*t*t*t+2)+b;
	}

	/**
	* Generates quartic easing out-in tween where equation for motion is based on the power of five and motion starts slow and becomes quite fast in what appears to be a fairly pronounced curve.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outInQuint(t:Float, b:Float, c:Float, d:Float):Float {
		t /= d/2;
		return c/2*(--t*t*t*t*t+1)+b;
	}

	/**
	* Generates sinusoidal easing in tween where equation for motion is based on a sine or cosine function.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inSine(t:Float, b:Float, c:Float, d:Float):Float {
		return -c*Math.cos(t/d*(Math.PI/2))+c+b;
	}

	/**
	* Generates sinusoidal easing out tween where equation for motion is based on a sine or cosine function.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outSine(t:Float, b:Float, c:Float, d:Float):Float {
		return c*Math.sin(t/d*(Math.PI/2))+b;
	}

	/**
	* Generates sinusoidal easing in-out tween where equation for motion is based on a sine or cosine function.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inOutSine(t:Float, b:Float, c:Float, d:Float):Float {
		return -c/2*(Math.cos(Math.PI*t/d)-1)+b;
	}

	/**
	* Generates sinusoidal easing out-in tween where equation for motion is based on a sine or cosine function.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outInSine(t:Float, b:Float, c:Float, d:Float):Float {
		if ((t /= d/2)<1) {
			return c/2*(Math.sin(Math.PI*t/2))+b;
		}
		return -c/2*(Math.cos(Math.PI*--t/2)-2)+b;
	}

	/**
	* Generates circular easing in tween where equation for motion is based on the equation for half of a circle, which uses a square root.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inCirc(t:Float, b:Float, c:Float, d:Float):Float {
		return -c*(Math.sqrt(1-(t /= d)*t)-1)+b;
	}

	/**
	* Generates circular easing out tween where equation for motion is based on the equation for half of a circle, which uses a square root.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outCirc(t:Float, b:Float, c:Float, d:Float):Float {
		return c*Math.sqrt(1-(t=t/d-1)*t)+b;
	}

	/**
	* Generates circular easing in-out tween where equation for motion is based on the equation for half of a circle, which uses a square root.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function inOutCirc(t:Float, b:Float, c:Float, d:Float):Float {
		if ((t /= d/2)<1) {
			return -c/2*(Math.sqrt(1-t*t)-1)+b;
		}
		return c/2*(Math.sqrt(1-(t -= 2)*t)+1)+b;
	}

	/**
	* Generates circular easing out-in tween where equation for motion is based on the equation for half of a circle, which uses a square root.
	* @param t		time
	* @param b		beginning position
	* @param c		total change in position
	* @param d		duration of the tween
	* @return		position
	*/
	public static function outInCirc(t:Float, b:Float, c:Float, d:Float):Float {
		if ((t /= d/2)<1) {
			return c/2*Math.sqrt(1- --t*t)+b;
		}
		return c/2*(2-Math.sqrt(1- --t*t))+b;
	}
}
