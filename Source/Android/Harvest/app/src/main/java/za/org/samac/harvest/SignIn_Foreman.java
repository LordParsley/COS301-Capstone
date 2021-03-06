package za.org.samac.harvest;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.text.method.KeyListener;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseException;
import com.google.firebase.FirebaseTooManyRequestsException;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.List;
import java.util.Vector;
import java.util.concurrent.TimeUnit;

import za.org.samac.harvest.util.AppUtil;

public class SignIn_Foreman extends AppCompatActivity {

    private  static  final  String KEY_VERIFY_IN_PROGRESS = "key_verify_in_progress";

    private static final int STATE_START = 0;
    private static final int STATE_CODE_SENT = 1;
    private static final int STATE_VERIFY_FAIL = 2;
    private static final int STATE_INVALID_NUMBER = 3;
    private static final int STATE_QUOTA_EXCEED = 4;
    private static final int STATE_FARM_NONE = 5;
    private static final int STATE_FARM_ONE = 6;
    private static final int STATE_FARM_MULTI = 7;
    private int state;

    private EditText phoneNumberField;
    private KeyListener phoneNumberFieldListener;
    private TextView SMSWarning;
    private Button logInButt;
    private TextView verificationTip;
    private EditText verificationField;
    private KeyListener verificationFieldListener;
    private LinearLayout verificationButts;
    private Button verificationOkay;
    private TextView phoneConfTip;
    private TextView phoneConfLook;
    private TextView farmTip;
    private Spinner farmChoose;
    private TextView farmOneLook;
    private Button farmOkay;

    private String mVerificationId;
    private PhoneAuthProvider.ForceResendingToken mResendToken;

    private PhoneAuthProvider.OnVerificationStateChangedCallbacks phoneCallback;
    private boolean verificationInProgress = false;
    private FirebaseAuth mAuth;

    private String systemPhone;
    private List<Organization> organizations;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_signin_foreman);


        //Restore Instance State
        if (savedInstanceState != null){
            onRestoreInstanceState(savedInstanceState);
        }

        mAuth = FirebaseAuth.getInstance();

        phoneNumberField = findViewById(R.id.signIn_foreman_phone_edit);
        phoneNumberFieldListener = phoneNumberField.getKeyListener();
        SMSWarning = findViewById(R.id.signIn_foreman_warning);
        logInButt = findViewById(R.id.signIn_foreman_logIn_butt);
        verificationTip = findViewById(R.id.signIn_foreman_verificationTip);
        verificationField = findViewById(R.id.signIn_foreman_verifyCode_edit);
        verificationFieldListener = verificationField.getKeyListener();
        verificationButts = findViewById(R.id.signIn_foreman_verification_butts);
        verificationOkay = findViewById(R.id.signIn_foreman_verification_okayButt);
        phoneConfTip = findViewById(R.id.signIn_foreman_phoneConf_tip);
        phoneConfLook = findViewById(R.id.signIn_foreman_phoneConf_Look);
        farmTip = findViewById(R.id.signIn_foreman_farm_tip);
        farmChoose = findViewById(R.id.signIn_foreman_farmChoose_Spinner);
        farmOneLook = findViewById(R.id.signIn_foreman_farmOne_look);
        farmOkay = findViewById(R.id.signIn_foreman_farm_okay);

        state = STATE_START;
        updateUI();

        organizations = new Vector<>();

        phoneCallback = new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
            @Override
            //Automatic verification -- no user action necessary
            public void onVerificationCompleted(PhoneAuthCredential phoneAuthCredential) {
                verificationInProgress = false;
                signInWithPhoneAuthCredential(phoneAuthCredential);
            }

            @Override
            public void onVerificationFailed(FirebaseException e) {
                verificationInProgress = false;
                if (e instanceof FirebaseAuthInvalidCredentialsException){
                    state = STATE_INVALID_NUMBER;
                    updateUI();
                }
                else if (e instanceof FirebaseTooManyRequestsException){
                    //SMS quota for the project has been exceeded.
                    state = STATE_QUOTA_EXCEED;
                    updateUI();
                }
                else {
                    phoneNumberField.setError(e.getMessage());
                }
                logInButt.setBackgroundColor(getResources().getColor(R.color.colorPrimary));
                logInButt.setEnabled(true);
//                phoneNumberField.setFocusable(true);
                phoneNumberField.setKeyListener(phoneNumberFieldListener);
            }

            @Override
            public void onCodeSent(String s, PhoneAuthProvider.ForceResendingToken forceResendingToken) {
//                super.onCodeSent(s, forceResendingToken);
                mVerificationId = s;
                mResendToken = forceResendingToken;
                state = STATE_CODE_SENT;
                updateUI();

                //Set Focus to verification field
                verificationField.requestFocus();
            }
        };
    }

    @Override
    protected void onStart() {
        super.onStart();

        if(verificationInProgress){
            startPhoneNumberVerification(phoneNumberField.getText().toString());
        }

    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putBoolean(KEY_VERIFY_IN_PROGRESS, verificationInProgress);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        verificationInProgress = savedInstanceState.getBoolean(KEY_VERIFY_IN_PROGRESS);
    }

    private void startPhoneNumberVerification(String phoneNumber){
        PhoneAuthProvider.getInstance().verifyPhoneNumber(
                phoneNumber,
                60,
                TimeUnit.SECONDS,
                this,
                phoneCallback
        );

        verificationInProgress = true;
    }

    private void verifyPhoneNumberWithCode(String verificationId, String code){
        PhoneAuthCredential credential = PhoneAuthProvider.getCredential(verificationId, code);
        signInWithPhoneAuthCredential(credential);
    }

    private void resendVerificationCode(String phoneNumber, PhoneAuthProvider.ForceResendingToken token){
        PhoneAuthProvider.getInstance().verifyPhoneNumber(
                phoneNumber,
                60,
                TimeUnit.SECONDS,
                this,
                phoneCallback,
                token
        );
    }

    private void signInWithPhoneAuthCredential(PhoneAuthCredential credential){
        mAuth.signInWithCredential(credential).addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
            @Override
            public void onComplete(@NonNull Task<AuthResult> task) {
                if (task.isSuccessful()){
                    systemPhone = mAuth.getCurrentUser().getPhoneNumber();
                    verificationInProgress = false;
                    findFarms();
                }
                else {
                    verificationField.setError("Incorrect");

                    verificationOkay.setBackgroundColor(getResources().getColor(R.color.colorPrimary));
                    verificationOkay.setEnabled(true);
                }
            }
        });
    }

    public void signInForemanButtClick(View v){
        switch (v.getId()){
            case R.id.signIn_foreman_logIn_butt:
                if (TextUtils.isEmpty(phoneNumberField.getText().toString())){
                    phoneNumberField.setError("Cannot be Empty");
                    return;
                }
//                phoneNumberField.setFocusable(false);
                phoneNumberField.setKeyListener(null);
//                phoneNumberField.setBackgroundColor(getResources().getColor(R.color.androidGrey));
                String number = phoneNumberField.getText().toString();

                number = AppUtil.normalisePhoneNumber(number, this);
                
                startPhoneNumberVerification(number);
                v.setEnabled(false);
                v.setBackgroundColor(getResources().getColor(R.color.androidGrey));
                break;
            case R.id.signIn_foreman_verification_okayButt:
                String code = verificationField.getText().toString();
                if (TextUtils.isEmpty(code)){
                    verificationField.setError("Cannot be Empty");
                    return;
                }

                v.setEnabled(false);
                v.setBackgroundColor(getResources().getColor(R.color.androidGrey));

                verifyPhoneNumberWithCode(mVerificationId, code);
                break;
            case R.id.signIn_foreman_verification_resendButt:
                resendVerificationCode(phoneNumberField.getText().toString(), mResendToken);
                //TODO: Some visual feedback
                break;
            case R.id.signIn_foreman_farm_okay:
                switch (state){
                    case STATE_FARM_ONE:
                        AppUtil.writeStringToSharedPrefs(this, getString(R.string.farmerID_Pref), organizations.get(0).getID());
                        Intent openMain = new Intent(this, MainActivity.class);
                        startActivityIfNeeded(openMain, 0);
                        break;
                    case STATE_FARM_MULTI:
                        String id = ((Organization) farmChoose.getSelectedItem()).getID();
                        AppUtil.writeStringToSharedPrefs(this, getString(R.string.farmerID_Pref), id);
                        Intent openMain1 = new Intent(this, MainActivity.class);
                        startActivityIfNeeded(openMain1, 0);
                        break;
                }
                finish();
                break;
            case R.id.signIn_foreman_verification_cancel:
                state = STATE_START;
                updateUI();
                break;
        }
    }

    public void findFarms(){

        organizations.clear();
        final FirebaseDatabase database = FirebaseDatabase.getInstance();
        DatabaseReference workingFor = database.getReference("/WorkingFor/" + AppUtil.Hash.SHA256(systemPhone));
        workingFor.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {

                for (DataSnapshot child : dataSnapshot.getChildren()){
                    organizations.add(new Organization(child.getKey()));
                }

                if (organizations.size() == 0){
                    state = STATE_FARM_NONE;
                    updateUI();
                    return;
                }

                final int updated[] = {0};

                for (final Organization org : organizations) {
                    DatabaseReference orgAdmin = database.getReference("/" + org.getID() + "/admin/");
                    orgAdmin.addValueEventListener(new ValueEventListener() {
                        @Override
                        public void onDataChange(DataSnapshot dataSnapshot) {
                            String orgName = dataSnapshot.child("organization").getValue(String.class);
                            if (orgName != null) {
                                if (!orgName.equals("")) {
                                    org.setOrganizationName(orgName);
                                }
                            }
                            if (org.toString() == null) {
                                org.setOrganizationName(dataSnapshot.child("email").getValue(String.class));
                            }

                            updated[0]++;

                            if (updated[0] == organizations.size()){
                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        switch (organizations.size()){
                                            case 0:
                                                state = STATE_FARM_NONE;
                                                break;
                                            case 1:
                                                state = STATE_FARM_ONE;
                                                break;
                                            default:
                                                state = STATE_FARM_MULTI;
                                                break;
                                        }
                                        updateUI();
                                    }
                                });
                            }

                        }

                        @Override
                        public void onCancelled(DatabaseError databaseError) {
                            organizations.remove(org);

                            if (updated[0] == organizations.size()){
                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        switch (organizations.size()){
                                            case 0:
                                                state = STATE_FARM_NONE;
                                                break;
                                            case 1:
                                                state = STATE_FARM_ONE;
                                                break;
                                            default:
                                                state = STATE_FARM_MULTI;
                                                break;
                                        }
                                        updateUI();
                                    }
                                });
                            }

                            //TODO: Notify foreman they are not authorized, if it's even possible for such a situation to occur.
                        }
                    });
                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {

            }
        });
    }

    private void updateUI(){
        switch (this.state){
            case STATE_START:
                phoneNumberField.setVisibility(View.VISIBLE);
                phoneNumberField.setKeyListener(phoneNumberFieldListener);
                SMSWarning.setVisibility(View.VISIBLE);
                logInButt.setVisibility(View.VISIBLE);
                logInButt.setEnabled(true);
                logInButt.setBackgroundColor(getResources().getColor(R.color.colorPrimary));
                verificationTip.setVisibility(View.GONE);
                verificationField.setVisibility(View.GONE);
                verificationButts.setVisibility(View.GONE);
                phoneConfTip.setVisibility(View.GONE);
                phoneConfLook.setVisibility(View.GONE);
                farmTip.setVisibility(View.GONE);
                farmChoose.setVisibility(View.GONE);
                farmOneLook.setVisibility(View.GONE);
                farmOkay.setVisibility(View.GONE);
                break;
            case STATE_CODE_SENT:
                verificationTip.setVisibility(View.VISIBLE);
                verificationField.setVisibility(View.VISIBLE);
                verificationButts.setVisibility(View.VISIBLE);
                logInButt.setVisibility(View.GONE);
                SMSWarning.setVisibility(View.GONE);
                break;
            case STATE_VERIFY_FAIL:
                verificationField.setError(getString(R.string.signIn_foreman_fail));
                break;
            case STATE_INVALID_NUMBER:
                phoneNumberField.setError(getString(R.string.signIn_foreman_fail_invalidNumber));
                break;
            case STATE_QUOTA_EXCEED:
                phoneNumberField.setError(getString(R.string.signIn_foreman_fail_SMS));
                break;
            case STATE_FARM_NONE:
                showConfirmationBasics();
                farmTip.setText(R.string.signIn_foreman_farmNone);
                farmTip.setTextColor(getResources().getColor(android.R.color.holo_red_dark));
                farmOkay.setText(R.string.signIn_foreman_goBack);
                mAuth.signOut();
                break;
            case STATE_FARM_ONE:
                showConfirmationBasics();
                farmTip.setText(R.string.signIn_foreman_farmOne);
                farmOneLook.setVisibility(View.VISIBLE);
                farmOneLook.setText(organizations.get(0).toString());
                farmOkay.setText(getText(R.string.signIn_foreman_verificationOkay));
                break;
            case STATE_FARM_MULTI:
                showConfirmationBasics();
                farmTip.setText(R.string.signIn_foreman_farmChooseTip);
                farmChoose.setVisibility(View.VISIBLE);
                ArrayAdapter sAdapter = new ArrayAdapter(this, android.R.layout.simple_spinner_item, organizations);
                farmChoose.setAdapter(sAdapter);
                farmOkay.setText(getText(R.string.signIn_foreman_verificationOkay));
                break;
        }
    }

    private void showConfirmationBasics() {
        phoneNumberField.setVisibility(View.GONE);
        SMSWarning.setVisibility(View.GONE);
        logInButt.setVisibility(View.GONE);
        verificationTip.setVisibility(View.GONE);
        verificationField.setVisibility(View.GONE);
        verificationButts.setVisibility(View.GONE);
        phoneConfTip.setVisibility(View.VISIBLE);
        phoneConfLook.setVisibility(View.VISIBLE);
        phoneConfLook.setText(systemPhone);
        farmTip.setVisibility(View.VISIBLE);
        farmOkay.setVisibility(View.VISIBLE);
    }

    class Organization{
        private String organization, id;

        Organization(String id){
            this.id = id;
        }

        public void setOrganizationName(String name){
            organization = name;
        }

        public String toString(){
            if (organization != null) {
                return organization;
            }
            return id;
        }

        public String getID(){
            return id;
        }
    }
}
