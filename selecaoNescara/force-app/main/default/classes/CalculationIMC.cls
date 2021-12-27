public with sharing class CalculationIMC {
    public CalculationIMC() { }

    public static IMCInfo checkIMC(Decimal weight, Decimal height, String gender){
        IMCInfo resultado = new IMCInfo();
        resultado.imc = calcIMC(weight, height);
        resultado.condition = getCondition(resultado.imc, gender);
        return resultado;
    }
    
    public static Decimal calcIMC(Decimal weight, Decimal height){
        Decimal calc = weight/(height*height);
        return calc;
    }

    public static String getCondition(Decimal imc, String gender){
        if ((imc<19.1 && gender=='Feminino')||(imc<20.7 && gender=='Masculino')) {
            return 'abaixo do peso';
        } else if((imc>=19.1 && imc>=25.8 && gender=='Feminino')||(imc>=20.7 && imc<26.4 && gender=='Masculino')) {
            return 'no peso normal';
        } else if((imc>=25.8 && imc>=27.3 && gender=='Feminino')||(imc>=26.4 && imc<27.8 && gender=='Masculino')) {
            return 'marginalmente acima do peso';
        } else if((imc>=27.3 && imc>=31.1 && gender=='Feminino')||(imc>=27.8 && imc<32.3 && gender=='Masculino')) {
            return 'acima do peso ideal';
        } else if((imc>31.1 && gender=='Feminino')||(imc>32.3 && gender=='Masculino')) {
            return 'obeso';
        }
        return '';
    }
    
    public class IMCInfo {
        String condition;
        Decimal imc;
    }
}