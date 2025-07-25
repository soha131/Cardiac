class XGBoostRequest {
  final double age;
  final String sex;
  final double bmi;
  final String ageGroup;
  final String bmiCategory;
  final String preopHtn;
  final String preopDm;
  final String preopEcg;
  final String preopPft;
  final double preopHb;
  final double preopPlt;
  final double preopPt;
  final double preopAptt;
  final double preopNa;
  final double preopK;
  final double preopGluc;
  final double preopAlb;
  final double preopAst;
  final double preopAlt;
  final double preopBun;
  final double preopCr;

  XGBoostRequest({
    required this.age,
    required this.sex,
    required this.bmi,
    required this.ageGroup,
    required this.bmiCategory,
    required this.preopHtn,
    required this.preopDm,
    required this.preopEcg,
    required this.preopPft,
    required this.preopHb,
    required this.preopPlt,
    required this.preopPt,
    required this.preopAptt,
    required this.preopNa,
    required this.preopK,
    required this.preopGluc,
    required this.preopAlb,
    required this.preopAst,
    required this.preopAlt,
    required this.preopBun,
    required this.preopCr,
  });

  Map<String, dynamic> toJson() => {
    "age": age,
    "sex": sex,
    "bmi": bmi,
    "age_group": ageGroup,
    "bmi_category": bmiCategory,
    "preop_htn": preopHtn,
    "preop_dm": preopDm,
    "preop_ecg": preopEcg,
    "preop_pft": preopPft,
    "preop_hb": preopHb,
    "preop_plt": preopPlt,
    "preop_pt": preopPt,
    "preop_aptt": preopAptt,
    "preop_na": preopNa,
    "preop_k": preopK,
    "preop_gluc": preopGluc,
    "preop_alb": preopAlb,
    "preop_ast": preopAst,
    "preop_alt": preopAlt,
    "preop_bun": preopBun,
    "preop_cr": preopCr,
  };
}

class CnnRequest {
  final List<double> ecgSignal;

  CnnRequest({required this.ecgSignal});

  Map<String, dynamic> toJson() => {
    "ecg_signal": ecgSignal,
  };
}

class LstmRequest {
  final List<List<double>> data; // 60 x 6

  LstmRequest({required this.data});

  Map<String, dynamic> toJson() => {
    "data": data,
  };
}
